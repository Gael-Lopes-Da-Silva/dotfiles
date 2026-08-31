use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use std::process::Command;
use std::rc::Rc;
use std::time::Duration;

use component::{Component, spawn_background};
use gtk4::glib;
use gtk4::pango;
use gtk4::prelude::*;
use gtk4::{self as gtk};
use libadwaita as adw;

#[derive(Clone, Debug)]
struct Endpoint {
    id: u32,
    name: String,
    volume: f64,
    muted: bool,
    is_default: bool,
}

#[derive(Clone, Debug)]
struct Stream {
    id: u32,
    app_name: String,
    media_name: String,
    binary: String,
    volume: f64,
    muted: bool,
    is_output: bool,
}

struct UiState {
    dragging: HashSet<u32>,
    device_ids: Vec<u32>,
    stream_ids: Vec<u32>,
    updating: bool,
    refreshing: bool,
}

struct AudioSnapshot {
    sinks: Vec<Endpoint>,
    sources: Vec<Endpoint>,
    streams: Vec<Stream>,
}

pub fn component() -> Component {
    Component {
        id: "audio",
        title: "Audio",
        icon: "audio-volume-high-symbolic",
        build,
    }
}

fn build() -> gtk::Widget {
    let root = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(6)
        .build();

    let stack = adw::ViewStack::new();
    stack.set_vexpand(true);

    let output_devices = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(4)
        .build();
    let output_streams = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(4)
        .build();
    let output_page = build_tab_page(&output_devices, &output_streams, true);
    stack.add_titled_with_icon(
        &output_page,
        Some("output"),
        "Output",
        "audio-volume-high-symbolic",
    );

    let input_devices = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(4)
        .build();
    let input_streams = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(4)
        .build();
    let input_page = build_tab_page(&input_devices, &input_streams, false);
    stack.add_titled_with_icon(
        &input_page,
        Some("input"),
        "Input",
        "audio-input-microphone-symbolic",
    );

    let switcher = adw::ViewSwitcher::builder()
        .stack(&stack)
        .policy(adw::ViewSwitcherPolicy::Wide)
        .halign(gtk::Align::Center)
        .margin_top(6)
        .build();

    root.append(&switcher);
    root.append(&stack);

    let output_devices_w = output_devices.downgrade();
    let output_streams_w = output_streams.downgrade();
    let input_devices_w = input_devices.downgrade();
    let input_streams_w = input_streams.downgrade();

    let state = Rc::new(RefCell::new(UiState {
        dragging: HashSet::new(),
        device_ids: Vec::new(),
        stream_ids: Vec::new(),
        updating: false,
        refreshing: false,
    }));

    let refresh = Rc::new(glib::clone!(
        #[strong]
        output_devices_w,
        #[strong]
        output_streams_w,
        #[strong]
        input_devices_w,
        #[strong]
        input_streams_w,
        #[strong]
        state,
        move || {
            if state.borrow().refreshing {
                return;
            }
            state.borrow_mut().refreshing = true;

            spawn_background(
                fetch_audio_snapshot,
                glib::clone!(
                    #[strong]
                    output_devices_w,
                    #[strong]
                    output_streams_w,
                    #[strong]
                    input_devices_w,
                    #[strong]
                    input_streams_w,
                    #[strong]
                    state,
                    move |snapshot| {
                        state.borrow_mut().refreshing = false;
                        let Some(output_devices) = output_devices_w.upgrade() else {
                            return;
                        };
                        let Some(output_streams) = output_streams_w.upgrade() else {
                            return;
                        };
                        let Some(input_devices) = input_devices_w.upgrade() else {
                            return;
                        };
                        let Some(input_streams) = input_streams_w.upgrade() else {
                            return;
                        };
                        apply_snapshot(
                            &output_devices,
                            &output_streams,
                            &input_devices,
                            &input_streams,
                            &state,
                            snapshot,
                        );
                    }
                ),
            );
        }
    ));

    refresh();

    glib::timeout_add_local(
        Duration::from_millis(1000),
        glib::clone!(
            #[strong]
            refresh,
            move || {
                refresh();
                glib::ControlFlow::Continue
            }
        ),
    );

    root.upcast()
}

fn build_tab_page(devices: &gtk::Box, streams: &gtk::Box, is_output: bool) -> gtk::ScrolledWindow {
    let content = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(12)
        .margin_start(12)
        .margin_end(12)
        .margin_top(8)
        .margin_bottom(12)
        .build();

    let devices_label = gtk::Label::builder()
        .label(if is_output {
            "Output Devices"
        } else {
            "Input Devices"
        })
        .xalign(0.0)
        .css_classes(["heading"])
        .build();
    content.append(&devices_label);
    content.append(devices);

    let streams_label = gtk::Label::builder()
        .label("Applications")
        .xalign(0.0)
        .margin_top(8)
        .css_classes(["heading"])
        .build();
    content.append(&streams_label);
    content.append(streams);

    gtk::ScrolledWindow::builder()
        .hscrollbar_policy(gtk::PolicyType::Never)
        .vexpand(true)
        .child(&content)
        .build()
}

fn fetch_audio_snapshot() -> AudioSnapshot {
    AudioSnapshot {
        sinks: list_endpoints(true),
        sources: list_endpoints(false),
        streams: list_streams(),
    }
}

fn apply_snapshot(
    output_devices: &gtk::Box,
    output_streams: &gtk::Box,
    input_devices: &gtk::Box,
    input_streams: &gtk::Box,
    state: &Rc<RefCell<UiState>>,
    snapshot: AudioSnapshot,
) {
    let sinks = snapshot.sinks;
    let sources = snapshot.sources;
    let streams = snapshot.streams;

    let mut device_ids: Vec<u32> = sinks.iter().map(|e| e.id).collect();
    device_ids.extend(sources.iter().map(|e| e.id));
    let stream_ids: Vec<u32> = streams.iter().map(|s| s.id).collect();

    let needs_rebuild = {
        let mut st = state.borrow_mut();
        let changed = st.device_ids != device_ids || st.stream_ids != stream_ids;
        if changed {
            st.device_ids = device_ids;
            st.stream_ids = stream_ids;
        }
        changed
    };

    state.borrow_mut().updating = true;
    if needs_rebuild {
        rebuild_device_list(output_devices, &sinks, true, state);
        rebuild_device_list(input_devices, &sources, false, state);
        rebuild_stream_list(
            output_streams,
            &streams
                .iter()
                .filter(|s| s.is_output)
                .cloned()
                .collect::<Vec<_>>(),
            true,
            state,
        );
        rebuild_stream_list(
            input_streams,
            &streams
                .iter()
                .filter(|s| !s.is_output)
                .cloned()
                .collect::<Vec<_>>(),
            false,
            state,
        );
    } else {
        update_device_rows(output_devices, &sinks, true, state);
        update_device_rows(input_devices, &sources, false, state);
        update_stream_rows(output_streams, &streams, true, state);
        update_stream_rows(input_streams, &streams, false, state);
    }
    state.borrow_mut().updating = false;
}

fn clear_box(container: &gtk::Box) {
    while let Some(child) = container.first_child() {
        container.remove(&child);
    }
}

fn rebuild_device_list(
    container: &gtk::Box,
    endpoints: &[Endpoint],
    is_output: bool,
    state: &Rc<RefCell<UiState>>,
) {
    clear_box(container);

    if endpoints.is_empty() {
        container.append(&empty_label("No devices found"));
        return;
    }

    let mut first_check: Option<gtk::CheckButton> = None;

    for endpoint in endpoints {
        let row = gtk::Box::builder()
            .orientation(gtk::Orientation::Horizontal)
            .spacing(10)
            .margin_top(4)
            .margin_bottom(4)
            .build();
        row.set_widget_name(&format!("endpoint-{}", endpoint.id));

        let check = gtk::CheckButton::builder()
            .active(endpoint.is_default)
            .tooltip_text("Set as default")
            .valign(gtk::Align::Center)
            .build();
        if let Some(ref first) = first_check {
            check.set_group(Some(first));
        } else {
            first_check = Some(check.clone());
        }

        let id = endpoint.id;
        check.connect_toggled(glib::clone!(
            #[strong]
            state,
            move |btn| {
                if state.borrow().updating {
                    return;
                }
                if btn.is_active() {
                    set_default(id);
                }
            }
        ));

        let icon_name = if is_output {
            "audio-speakers-symbolic"
        } else {
            "audio-input-microphone-symbolic"
        };
        let icon = gtk::Image::from_icon_name(icon_name);
        icon.set_pixel_size(20);
        icon.set_valign(gtk::Align::Center);

        let name = gtk::Label::builder()
            .label(&endpoint.name)
            .xalign(0.0)
            .hexpand(true)
            .ellipsize(pango::EllipsizeMode::End)
            .valign(gtk::Align::Center)
            .build();
        name.set_widget_name("name");

        let scale = volume_scale(endpoint.id, endpoint.volume, state);
        scale.set_widget_name("scale");

        let mute = mute_button(endpoint.id, endpoint.muted, is_output);
        mute.set_widget_name("mute");

        row.append(&check);
        row.append(&icon);
        row.append(&name);
        row.append(&scale);
        row.append(&mute);
        container.append(&row);
    }
}

fn rebuild_stream_list(
    container: &gtk::Box,
    streams: &[Stream],
    is_output: bool,
    state: &Rc<RefCell<UiState>>,
) {
    clear_box(container);

    if streams.is_empty() {
        container.append(&empty_label("No active streams"));
        return;
    }

    let icon_theme = gtk::IconTheme::for_display(&gtk::gdk::Display::default().unwrap());

    for stream in streams {
        let row = gtk::Box::builder()
            .orientation(gtk::Orientation::Horizontal)
            .spacing(10)
            .margin_top(4)
            .margin_bottom(4)
            .build();
        row.set_widget_name(&format!("stream-{}", stream.id));

        let icon_name = resolve_app_icon(&icon_theme, &stream.binary, &stream.app_name);
        let icon = gtk::Image::from_icon_name(&icon_name);
        icon.set_pixel_size(24);
        icon.set_valign(gtk::Align::Center);

        let text_col = gtk::Box::builder()
            .orientation(gtk::Orientation::Vertical)
            .spacing(2)
            .hexpand(true)
            .valign(gtk::Align::Center)
            .build();

        let app = gtk::Label::builder()
            .label(&stream.app_name)
            .xalign(0.0)
            .ellipsize(pango::EllipsizeMode::End)
            .build();
        app.set_widget_name("app");

        let media = gtk::Label::builder()
            .label(if stream.media_name.is_empty() {
                " "
            } else {
                &stream.media_name
            })
            .xalign(0.0)
            .ellipsize(pango::EllipsizeMode::End)
            .css_classes(["dim-label", "caption"])
            .build();
        media.set_widget_name("media");

        text_col.append(&app);
        text_col.append(&media);

        let scale = volume_scale(stream.id, stream.volume, state);
        scale.set_widget_name("scale");

        let mute = mute_button(stream.id, stream.muted, is_output);
        mute.set_widget_name("mute");

        row.append(&icon);
        row.append(&text_col);
        row.append(&scale);
        row.append(&mute);
        container.append(&row);
    }
}

fn update_device_rows(
    container: &gtk::Box,
    endpoints: &[Endpoint],
    is_output: bool,
    state: &Rc<RefCell<UiState>>,
) {
    let by_id: HashMap<u32, &Endpoint> = endpoints.iter().map(|e| (e.id, e)).collect();
    let mut child = container.first_child();
    while let Some(widget) = child {
        child = widget.next_sibling();
        let Some(id) = parse_named_id(widget.widget_name().as_str(), "endpoint-") else {
            continue;
        };
        let Some(endpoint) = by_id.get(&id) else {
            continue;
        };
        if let Some(row) = widget.downcast_ref::<gtk::Box>() {
            if let Some(check) = find_child_as::<gtk::CheckButton>(row)
                && check.is_active() != endpoint.is_default
            {
                check.set_active(endpoint.is_default);
            }
            if let Some(name) = find_named_as::<gtk::Label>(row, "name")
                && name.label() != endpoint.name.as_str()
            {
                name.set_label(&endpoint.name);
            }
            if !state.borrow().dragging.contains(&id)
                && let Some(scale) = find_named_as::<gtk::Scale>(row, "scale")
                && (scale.value() - endpoint.volume).abs() > 0.005
            {
                scale.set_value(endpoint.volume);
            }
            if let Some(mute) = find_named_as::<gtk::Button>(row, "mute") {
                set_mute_icon(&mute, endpoint.muted, is_output);
            }
        }
    }
}

fn update_stream_rows(
    container: &gtk::Box,
    streams: &[Stream],
    is_output: bool,
    state: &Rc<RefCell<UiState>>,
) {
    let by_id: HashMap<u32, &Stream> = streams
        .iter()
        .filter(|s| s.is_output == is_output)
        .map(|s| (s.id, s))
        .collect();
    let mut child = container.first_child();
    while let Some(widget) = child {
        child = widget.next_sibling();
        let Some(id) = parse_named_id(widget.widget_name().as_str(), "stream-") else {
            continue;
        };
        let Some(stream) = by_id.get(&id) else {
            continue;
        };
        if let Some(row) = widget.downcast_ref::<gtk::Box>() {
            if let Some(app) = find_named_as::<gtk::Label>(row, "app")
                && app.label() != stream.app_name.as_str()
            {
                app.set_label(&stream.app_name);
            }
            if let Some(media) = find_named_as::<gtk::Label>(row, "media") {
                let text = if stream.media_name.is_empty() {
                    " "
                } else {
                    stream.media_name.as_str()
                };
                if media.label() != text {
                    media.set_label(text);
                }
            }
            if !state.borrow().dragging.contains(&id)
                && let Some(scale) = find_named_as::<gtk::Scale>(row, "scale")
                && (scale.value() - stream.volume).abs() > 0.005
            {
                scale.set_value(stream.volume);
            }
            if let Some(mute) = find_named_as::<gtk::Button>(row, "mute") {
                set_mute_icon(&mute, stream.muted, is_output);
            }
        }
    }
}

fn volume_scale(id: u32, volume: f64, state: &Rc<RefCell<UiState>>) -> gtk::Scale {
    let scale = gtk::Scale::with_range(gtk::Orientation::Horizontal, 0.0, 1.5, 0.01);
    scale.set_value(volume.clamp(0.0, 1.5));
    scale.set_draw_value(true);
    scale.set_value_pos(gtk::PositionType::Right);
    scale.set_size_request(180, -1);
    scale.set_hexpand(true);
    scale.set_valign(gtk::Align::Center);
    scale.set_format_value_func(|_, value| format!("{:.0}%", value * 100.0));

    scale.connect_change_value(glib::clone!(
        #[strong]
        state,
        move |_, _, value| {
            state.borrow_mut().dragging.insert(id);
            set_volume(id, value);
            glib::Propagation::Proceed
        }
    ));

    let click = gtk::GestureClick::new();
    click.connect_pressed(glib::clone!(
        #[strong]
        state,
        move |_, _, _, _| {
            state.borrow_mut().dragging.insert(id);
        }
    ));
    click.connect_released(glib::clone!(
        #[strong]
        state,
        move |_, _, _, _| {
            state.borrow_mut().dragging.remove(&id);
        }
    ));
    scale.add_controller(click);

    scale
}

fn mute_button(id: u32, muted: bool, is_output: bool) -> gtk::Button {
    let btn = gtk::Button::builder()
        .valign(gtk::Align::Center)
        .has_frame(false)
        .tooltip_text("Toggle mute")
        .build();
    set_mute_icon(&btn, muted, is_output);
    btn.connect_clicked(move |btn| {
        toggle_mute(id);
        let muted = get_volume(id).map(|(_, m)| m).unwrap_or(false);
        set_mute_icon(btn, muted, is_output);
    });
    btn
}

fn set_mute_icon(btn: &gtk::Button, muted: bool, is_output: bool) {
    let icon = match (muted, is_output) {
        (true, true) => "audio-volume-muted-symbolic",
        (false, true) => "audio-volume-high-symbolic",
        (true, false) => "microphone-sensitivity-muted-symbolic",
        (false, false) => "audio-input-microphone-symbolic",
    };
    btn.set_icon_name(icon);
}

fn empty_label(text: &str) -> gtk::Label {
    gtk::Label::builder()
        .label(text)
        .xalign(0.0)
        .css_classes(["dim-label"])
        .margin_start(4)
        .margin_bottom(4)
        .build()
}

fn resolve_app_icon(theme: &gtk::IconTheme, binary: &str, app_name: &str) -> String {
    for candidate in [binary, app_name] {
        if candidate.is_empty() {
            continue;
        }
        let lower = candidate.to_lowercase();
        for name in [
            candidate,
            &lower,
            &format!("{candidate}-symbolic"),
            &format!("{lower}-symbolic"),
        ] {
            if theme.has_icon(name) {
                return name.to_string();
            }
        }
    }
    "application-x-executable-symbolic".to_string()
}

fn parse_named_id(name: &str, prefix: &str) -> Option<u32> {
    name.strip_prefix(prefix)?.parse().ok()
}

fn find_named_as<T: IsA<gtk::Widget>>(parent: &gtk::Box, name: &str) -> Option<T> {
    let mut child = parent.first_child();
    while let Some(widget) = child {
        if widget.widget_name() == name {
            return widget.downcast::<T>().ok();
        }
        if let Some(box_) = widget.downcast_ref::<gtk::Box>()
            && let Some(found) = find_named_as::<T>(box_, name)
        {
            return Some(found);
        }
        child = widget.next_sibling();
    }
    None
}

fn find_child_as<T: IsA<gtk::Widget>>(parent: &gtk::Box) -> Option<T> {
    let mut child = parent.first_child();
    while let Some(widget) = child {
        if let Ok(typed) = widget.clone().downcast::<T>() {
            return Some(typed);
        }
        child = widget.next_sibling();
    }
    None
}

fn list_endpoints(sinks: bool) -> Vec<Endpoint> {
    let output = Command::new("wpctl")
        .arg("status")
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .unwrap_or_default();

    let section = if sinks { "Sinks:" } else { "Sources:" };
    let mut in_section = false;
    let mut endpoints = Vec::new();

    for line in output.lines() {
        let trimmed = strip_tree_chars(line);
        if trimmed.ends_with("Sinks:")
            || trimmed.ends_with("Sources:")
            || trimmed.ends_with("Filters:")
            || trimmed.ends_with("Streams:")
            || trimmed.ends_with("Devices:")
        {
            in_section = trimmed.ends_with(section);
            continue;
        }
        if !in_section || trimmed.is_empty() {
            continue;
        }

        let is_default = trimmed.contains('*');
        let cleaned = trimmed.replace('*', " ");
        if let Some((id, name, volume)) = parse_endpoint_line(&cleaned) {
            let (vol, muted) = get_volume(id).unwrap_or((volume, false));
            endpoints.push(Endpoint {
                id,
                name,
                volume: vol,
                muted,
                is_default,
            });
        }
    }

    endpoints
}

fn list_streams() -> Vec<Stream> {
    let output = Command::new("wpctl")
        .arg("status")
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())
        .unwrap_or_default();

    let mut in_streams = false;
    let mut in_audio = false;
    let mut stream_ids = Vec::new();

    for line in output.lines() {
        if line.starts_with("Audio") {
            in_audio = true;
            continue;
        }
        if line.starts_with("Video") || line.starts_with("Settings") {
            break;
        }
        if !in_audio {
            continue;
        }

        let trimmed = strip_tree_chars(line);
        if trimmed.ends_with("Streams:") {
            in_streams = true;
            continue;
        }
        if trimmed.ends_with("Sinks:")
            || trimmed.ends_with("Sources:")
            || trimmed.ends_with("Filters:")
            || trimmed.ends_with("Devices:")
        {
            in_streams = false;
            continue;
        }
        if !in_streams || trimmed.is_empty() {
            continue;
        }

        // Port lines are more indented and contain " > ".
        if line.contains(" > ") || trimmed.contains("output_") || trimmed.contains("input_") {
            if trimmed.contains('.') && trimmed.contains('[') {
                continue;
            }
            if line.starts_with("            ") || line.starts_with("\t\t") {
                continue;
            }
        }

        // Parent stream: "72. Firefox"
        if let Some((id, name)) = parse_stream_line(&trimmed) {
            // Skip port-looking names
            if name.contains(" > ") {
                continue;
            }
            stream_ids.push((id, name));
        }
    }

    let mut streams = Vec::new();
    for (id, fallback_name) in stream_ids {
        let details = inspect_stream(id);
        let is_output = details.as_ref().map(|d| d.is_output).unwrap_or(true);
        let (volume, muted) = get_volume(id).unwrap_or((1.0, false));
        let app_name = details
            .as_ref()
            .map(|d| d.app_name.clone())
            .filter(|s| !s.is_empty())
            .unwrap_or(fallback_name);
        let media_name = details
            .as_ref()
            .map(|d| d.media_name.clone())
            .unwrap_or_default();
        let binary = details
            .as_ref()
            .map(|d| d.binary.clone())
            .unwrap_or_default();

        streams.push(Stream {
            id,
            app_name,
            media_name,
            binary,
            volume,
            muted,
            is_output,
        });
    }
    streams
}

struct StreamDetails {
    app_name: String,
    media_name: String,
    binary: String,
    is_output: bool,
}

fn inspect_stream(id: u32) -> Option<StreamDetails> {
    let output = Command::new("wpctl")
        .args(["inspect", &id.to_string()])
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())?;

    let mut app_name = String::new();
    let mut media_name = String::new();
    let mut binary = String::new();
    let mut media_class = String::new();
    let mut node_name = String::new();

    for line in output.lines() {
        if let Some(v) = prop_value(line, "application.name") {
            app_name = v;
        } else if let Some(v) = prop_value(line, "media.name") {
            media_name = v;
        } else if let Some(v) = prop_value(line, "application.process.binary") {
            binary = v;
        } else if let Some(v) = prop_value(line, "media.class") {
            media_class = v;
        } else if let Some(v) = prop_value(line, "node.name") {
            node_name = v;
        }
    }

    if !media_class.contains("Stream/") {
        return None;
    }

    if app_name.is_empty() {
        app_name = node_name;
    }

    Some(StreamDetails {
        app_name,
        media_name,
        binary,
        is_output: media_class.contains("Output"),
    })
}

fn prop_value(line: &str, key: &str) -> Option<String> {
    let trimmed = line.trim();
    let marker = format!("{key} = \"");
    let idx = trimmed.find(&marker)?;
    let rest = &trimmed[idx + marker.len()..];
    let end = rest.find('"')?;
    Some(rest[..end].to_string())
}

fn get_volume(id: u32) -> Option<(f64, bool)> {
    let output = Command::new("wpctl")
        .args(["get-volume", &id.to_string()])
        .output()
        .ok()
        .and_then(|o| String::from_utf8(o.stdout).ok())?;

    // "Volume: 0.54" or "Volume: 0.54 [MUTED]"
    let muted = output.contains("[MUTED]");
    let volume = output.split_whitespace().nth(1)?.parse::<f64>().ok()?;
    Some((volume, muted))
}

fn set_volume(id: u32, volume: f64) {
    let vol = format!("{volume:.3}");
    let _ = Command::new("wpctl")
        .args(["set-volume", &id.to_string(), &vol])
        .status();
}

fn toggle_mute(id: u32) {
    let _ = Command::new("wpctl")
        .args(["set-mute", &id.to_string(), "toggle"])
        .status();
}

fn set_default(id: u32) {
    let _ = Command::new("wpctl")
        .args(["set-default", &id.to_string()])
        .status();
}

fn strip_tree_chars(line: &str) -> String {
    line.chars()
        .filter(|c| {
            c.is_ascii()
                || c.is_alphanumeric()
                || matches!(c, '*' | '.' | ':' | '[' | ']' | '/' | '-' | '_' | ' ' | '%')
        })
        .collect::<String>()
        .trim()
        .to_string()
}

fn parse_endpoint_line(line: &str) -> Option<(u32, String, f64)> {
    // "64. Built-in Audio Analog Stereo        [vol: 0.00]"
    let line = line.trim();
    let dot = line.find('.')?;
    let id: u32 = line[..dot].trim().parse().ok()?;
    let rest = line[dot + 1..].trim();
    let vol_idx = rest.rfind("[vol:")?;
    let name = rest[..vol_idx].trim().to_string();
    if name.is_empty() {
        return None;
    }
    let vol_part = rest[vol_idx..].trim_start_matches("[vol:").trim();
    let vol_str = vol_part.trim_end_matches(']').trim();
    let volume = vol_str.parse::<f64>().unwrap_or(0.0);
    Some((id, name, volume))
}

fn parse_stream_line(line: &str) -> Option<(u32, String)> {
    // "72. Firefox"
    let line = line.trim();
    if line.contains('[') || line.contains('>') {
        return None;
    }
    let dot = line.find('.')?;
    let id: u32 = line[..dot].trim().parse().ok()?;
    let name = line[dot + 1..].trim().to_string();
    if name.is_empty() {
        return None;
    }
    Some((id, name))
}
