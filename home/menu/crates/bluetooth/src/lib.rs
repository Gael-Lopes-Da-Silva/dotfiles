use std::cell::RefCell;
use std::collections::HashMap;
use std::process::{Command, Stdio};
use std::rc::Rc;
use std::time::Duration;

use component::{Component, spawn_background};
use gtk4::gio;
use gtk4::glib;
use gtk4::pango;
use gtk4::prelude::*;
use gtk4::{self as gtk};
use libadwaita as adw;
use libadwaita::prelude::*;

#[derive(Clone, Debug, Default)]
struct AdapterInfo {
    powered: bool,
    discovering: bool,
    address: String,
    name: String,
}

#[derive(Clone, Debug)]
struct BtDevice {
    address: String,
    name: String,
    icon: String,
    paired: bool,
    bonded: bool,
    trusted: bool,
    blocked: bool,
    connected: bool,
    battery: Option<u8>,
    rssi: Option<i32>,
    address_type: String,
    uuids: Vec<String>,
    modalias: String,
    class: String,
}

struct UiState {
    fingerprint: String,
    scanning: bool,
    updating: bool,
    refreshing: bool,
}

struct BluetoothSnapshot {
    adapter: AdapterInfo,
    devices: Vec<BtDevice>,
}

pub fn component() -> Component {
    Component {
        id: "bluetooth",
        title: "Bluetooth",
        icon: "bluetooth-active-symbolic",
        build: build,
    }
}

fn build() -> gtk::Widget {
    let root = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(6)
        .build();

    let power_switch = gtk::Switch::builder()
        .valign(gtk::Align::Center)
        .tooltip_text("Power")
        .build();

    let power_label = gtk::Label::builder()
        .label("Bluetooth")
        .css_classes(["heading"])
        .valign(gtk::Align::Center)
        .build();

    let scan_btn = gtk::Button::builder()
        .icon_name("edit-find-symbolic")
        .tooltip_text("Scan for devices")
        .valign(gtk::Align::Center)
        .build();

    let scan_spinner = gtk::Spinner::builder()
        .valign(gtk::Align::Center)
        .visible(false)
        .build();

    let header = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(10)
        .margin_start(12)
        .margin_end(12)
        .margin_top(8)
        .build();
    header.append(&power_label);
    header.append(&power_switch);
    let spacer = gtk::Box::builder().hexpand(true).build();
    header.append(&spacer);
    header.append(&scan_spinner);
    header.append(&scan_btn);

    let search = gtk::SearchEntry::builder()
        .placeholder_text("Filter devices…")
        .margin_start(12)
        .margin_end(12)
        .build();

    let connected_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(4)
        .build();
    let paired_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(4)
        .build();
    let other_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(4)
        .build();

    let content = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(12)
        .margin_start(12)
        .margin_end(12)
        .margin_top(8)
        .margin_bottom(12)
        .build();

    let connected_label = section_label("Connected");
    let paired_label = section_label("Paired");
    let other_label = section_label("Available");

    content.append(&connected_label);
    content.append(&connected_box);
    content.append(&paired_label);
    content.append(&paired_box);
    content.append(&other_label);
    content.append(&other_box);

    let scrolled = gtk::ScrolledWindow::builder()
        .hscrollbar_policy(gtk::PolicyType::Never)
        .vexpand(true)
        .child(&content)
        .build();

    root.append(&header);
    root.append(&search);
    root.append(&scrolled);

    let power_switch_w = power_switch.downgrade();
    let scan_btn_w = scan_btn.downgrade();
    let scan_spinner_w = scan_spinner.downgrade();
    let connected_box_w = connected_box.downgrade();
    let paired_box_w = paired_box.downgrade();
    let other_box_w = other_box.downgrade();
    let connected_label_w = connected_label.downgrade();
    let paired_label_w = paired_label.downgrade();
    let other_label_w = other_label.downgrade();

    let state = Rc::new(RefCell::new(UiState {
        fingerprint: String::new(),
        scanning: false,
        updating: false,
        refreshing: false,
    }));

    let query = Rc::new(RefCell::new(String::new()));

    let refresh: Rc<RefCell<Option<Rc<dyn Fn()>>>> = Rc::new(RefCell::new(None));

    let do_refresh = Rc::new(glib::clone!(
        #[strong]
        power_switch_w,
        #[strong]
        scan_btn_w,
        #[strong]
        scan_spinner_w,
        #[strong]
        connected_box_w,
        #[strong]
        paired_box_w,
        #[strong]
        other_box_w,
        #[strong]
        connected_label_w,
        #[strong]
        paired_label_w,
        #[strong]
        other_label_w,
        #[strong]
        state,
        #[strong]
        query,
        #[strong]
        refresh,
        move || {
            if state.borrow().refreshing {
                return;
            }
            state.borrow_mut().refreshing = true;

            let query_text = query.borrow().clone();
            spawn_background(
                fetch_bluetooth_snapshot,
                glib::clone!(
                    #[strong]
                    power_switch_w,
                    #[strong]
                    scan_btn_w,
                    #[strong]
                    scan_spinner_w,
                    #[strong]
                    connected_box_w,
                    #[strong]
                    paired_box_w,
                    #[strong]
                    other_box_w,
                    #[strong]
                    connected_label_w,
                    #[strong]
                    paired_label_w,
                    #[strong]
                    other_label_w,
                    #[strong]
                    state,
                    #[strong]
                    refresh,
                    move |snapshot| {
                        state.borrow_mut().refreshing = false;
                        let refresh_cb = refresh
                            .borrow()
                            .clone()
                            .unwrap_or_else(|| Rc::new(|| {}) as Rc<dyn Fn()>);
                        let Some(power_switch) = power_switch_w.upgrade() else {
                            return;
                        };
                        let Some(scan_btn) = scan_btn_w.upgrade() else {
                            return;
                        };
                        let Some(scan_spinner) = scan_spinner_w.upgrade() else {
                            return;
                        };
                        let Some(connected_box) = connected_box_w.upgrade() else {
                            return;
                        };
                        let Some(paired_box) = paired_box_w.upgrade() else {
                            return;
                        };
                        let Some(other_box) = other_box_w.upgrade() else {
                            return;
                        };
                        let Some(connected_label) = connected_label_w.upgrade() else {
                            return;
                        };
                        let Some(paired_label) = paired_label_w.upgrade() else {
                            return;
                        };
                        let Some(other_label) = other_label_w.upgrade() else {
                            return;
                        };
                        apply_snapshot(
                            &power_switch,
                            &scan_btn,
                            &scan_spinner,
                            &connected_box,
                            &paired_box,
                            &other_box,
                            &connected_label,
                            &paired_label,
                            &other_label,
                            &state,
                            &query_text,
                            refresh_cb,
                            snapshot,
                        );
                    }
                ),
            );
        }
    ));
    *refresh.borrow_mut() = Some(do_refresh.clone());

    power_switch.connect_state_set(glib::clone!(
        #[strong]
        state,
        #[strong]
        do_refresh,
        move |switch, active| {
            if state.borrow().updating {
                return glib::Propagation::Proceed;
            }
            set_powered(active);
            if !active {
                let _ = bt(&["scan", "off"]);
                state.borrow_mut().scanning = false;
            }
            // Defer refresh so switch animation completes.
            glib::timeout_add_local_once(Duration::from_millis(200), glib::clone!(
                #[strong]
                do_refresh,
                #[weak]
                switch,
                move || {
                    let _ = &switch;
                    do_refresh();
                }
            ));
            glib::Propagation::Proceed
        }
    ));

    scan_btn.connect_clicked(glib::clone!(
        #[strong]
        power_switch_w,
        #[strong]
        state,
        #[strong]
        do_refresh,
        move |_| {
            let Some(power_switch) = power_switch_w.upgrade() else {
                return;
            };
            if !power_switch.is_active() {
                return;
            }
            let scanning = state.borrow().scanning;
            if scanning {
                let _ = bt(&["scan", "off"]);
                state.borrow_mut().scanning = false;
            } else {
                let _ = bt(&["scan", "on"]);
                state.borrow_mut().scanning = true;
                // Auto-stop after 30s.
                glib::timeout_add_local_once(Duration::from_secs(30), glib::clone!(
                    #[strong]
                    state,
                    #[strong]
                    do_refresh,
                    move || {
                        if state.borrow().scanning {
                            let _ = bt(&["scan", "off"]);
                            state.borrow_mut().scanning = false;
                            do_refresh();
                        }
                    }
                ));
            }
            do_refresh();
        }
    ));

    search.connect_search_changed(glib::clone!(
        #[strong]
        query,
        #[strong]
        do_refresh,
        move |entry| {
            *query.borrow_mut() = entry.text().to_lowercase();
            do_refresh();
        }
    ));

    // Ensure an agent is available for pairing prompts.
    let _ = bt(&["agent", "NoInputNoOutput"]);
    let _ = bt(&["default-agent"]);

    do_refresh();

    glib::timeout_add_local(
        Duration::from_millis(1500),
        glib::clone!(
            #[strong]
            do_refresh,
            move || {
                do_refresh();
                glib::ControlFlow::Continue
            }
        ),
    );

    root.upcast()
}

fn section_label(text: &str) -> gtk::Label {
    gtk::Label::builder()
        .label(text)
        .xalign(0.0)
        .css_classes(["heading"])
        .build()
}

fn fetch_bluetooth_snapshot() -> BluetoothSnapshot {
    BluetoothSnapshot {
        adapter: adapter_info(),
        devices: list_devices(),
    }
}

fn apply_snapshot(
    power_switch: &gtk::Switch,
    scan_btn: &gtk::Button,
    scan_spinner: &gtk::Spinner,
    connected_box: &gtk::Box,
    paired_box: &gtk::Box,
    other_box: &gtk::Box,
    connected_label: &gtk::Label,
    paired_label: &gtk::Label,
    other_label: &gtk::Label,
    state: &Rc<RefCell<UiState>>,
    query: &str,
    refresh: Rc<dyn Fn()>,
    snapshot: BluetoothSnapshot,
) {
    let adapter = snapshot.adapter;
    let devices = snapshot.devices;

    let fingerprint = devices_fingerprint(&devices);
    let scanning = state.borrow().scanning || adapter.discovering;

    state.borrow_mut().updating = true;
    if power_switch.is_active() != adapter.powered {
        power_switch.set_active(adapter.powered);
    }
    scan_btn.set_sensitive(adapter.powered);
    scan_spinner.set_visible(scanning);
    if scanning {
        scan_spinner.start();
        scan_btn.set_icon_name("media-playback-stop-symbolic");
        scan_btn.set_tooltip_text(Some("Stop scanning"));
    } else {
        scan_spinner.stop();
        scan_btn.set_icon_name("edit-find-symbolic");
        scan_btn.set_tooltip_text(Some("Scan for devices"));
    }
    state.borrow_mut().updating = false;

    let filtered: Vec<BtDevice> = devices
        .into_iter()
        .filter(|d| {
            if query.is_empty() {
                return true;
            }
            d.name.to_lowercase().contains(query)
                || d.address.to_lowercase().contains(query)
        })
        .collect();

    let connected: Vec<_> = filtered.iter().filter(|d| d.connected).cloned().collect();
    let paired: Vec<_> = filtered
        .iter()
        .filter(|d| d.paired && !d.connected)
        .cloned()
        .collect();
    let other: Vec<_> = filtered
        .iter()
        .filter(|d| !d.paired && !d.connected)
        .cloned()
        .collect();

    let filter_key = format!("{query}|{fingerprint}");
    if state.borrow().fingerprint == filter_key {
        return;
    }
    state.borrow_mut().fingerprint = filter_key;

    rebuild_section(
        connected_box,
        connected_label,
        &connected,
        "No connected devices",
        &refresh,
    );
    rebuild_section(
        paired_box,
        paired_label,
        &paired,
        "No paired devices",
        &refresh,
    );
    rebuild_section(
        other_box,
        other_label,
        &other,
        "No available devices",
        &refresh,
    );
}

fn rebuild_section(
    container: &gtk::Box,
    label: &gtk::Label,
    devices: &[BtDevice],
    empty_text: &str,
    refresh: &Rc<dyn Fn()>,
) {
    clear_box(container);
    label.set_visible(true);

    if devices.is_empty() {
        container.append(&empty_label(empty_text));
        return;
    }

    for device in devices {
        container.append(&build_device_row(device, refresh.clone()));
    }
}

fn build_device_row(device: &BtDevice, refresh: Rc<dyn Fn()>) -> gtk::Box {
    let row = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(10)
        .margin_top(4)
        .margin_bottom(4)
        .build();

    let icon_name = resolve_device_icon(&device.icon);
    let icon = gtk::Image::from_icon_name(&icon_name);
    icon.set_pixel_size(28);
    icon.set_valign(gtk::Align::Center);

    let text_col = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(2)
        .hexpand(true)
        .valign(gtk::Align::Center)
        .build();

    let name = gtk::Label::builder()
        .label(&device.name)
        .xalign(0.0)
        .ellipsize(pango::EllipsizeMode::End)
        .build();

    let mut meta_parts = vec![device.address.clone()];
    if device.trusted {
        meta_parts.push("Trusted".into());
    }
    if device.blocked {
        meta_parts.push("Blocked".into());
    }
    if let Some(rssi) = device.rssi {
        meta_parts.push(format!("RSSI {rssi}"));
    }
    if device.connected {
        meta_parts.push("Connected".into());
    } else if device.paired {
        meta_parts.push("Paired".into());
    }

    let meta = gtk::Label::builder()
        .label(&meta_parts.join(" · "))
        .xalign(0.0)
        .ellipsize(pango::EllipsizeMode::End)
        .css_classes(["dim-label", "caption"])
        .build();

    text_col.append(&name);
    text_col.append(&meta);

    row.append(&icon);
    row.append(&text_col);
    if let Some(battery) = device.battery {
        row.append(&battery_indicator(battery));
    }

    let primary = primary_action_button(device, refresh.clone());

    let menu_btn = gtk::MenuButton::builder()
        .icon_name("view-more-symbolic")
        .has_frame(false)
        .valign(gtk::Align::Center)
        .tooltip_text("Device actions")
        .direction(gtk::ArrowType::Down)
        .build();

    let popover = build_actions_popover(device, &row, refresh);
    menu_btn.set_popover(Some(&popover));

    row.append(&primary);
    row.append(&menu_btn);
    row
}

fn battery_indicator(percent: u8) -> gtk::Widget {
    ensure_battery_css();

    let percent = percent.min(100);
    let level = if percent <= 15 {
        "critical"
    } else if percent <= 30 {
        "low"
    } else if percent <= 60 {
        "medium"
    } else {
        "ok"
    };

    let bar = gtk::ProgressBar::builder()
        .fraction(f64::from(percent) / 100.0)
        .show_text(false)
        .valign(gtk::Align::Center)
        .tooltip_text(format!("Battery {percent}%"))
        .css_classes(["bt-battery-bar", level])
        .build();
    bar.set_size_request(48, 6);
    bar.upcast()
}

fn ensure_battery_css() {
    use std::sync::Once;
    static LOAD: Once = Once::new();
    LOAD.call_once(|| {
        let provider = gtk::CssProvider::new();
        provider.load_from_string(
            "
            progressbar.bt-battery-bar {
                min-width: 48px;
                min-height: 6px;
            }
            progressbar.bt-battery-bar trough {
                border: none;
                border-radius: 3px;
                padding: 0;
                background-color: alpha(currentColor, 0.15);
                min-height: 6px;
            }
            progressbar.bt-battery-bar progress {
                border-radius: 3px;
                min-height: 6px;
                background-color: #3fb950;
            }
            progressbar.bt-battery-bar.medium progress {
                background-color: #d29922;
            }
            progressbar.bt-battery-bar.low progress {
                background-color: #db6d28;
            }
            progressbar.bt-battery-bar.critical progress {
                background-color: #f85149;
            }
            ",
        );
        if let Some(display) = gtk::gdk::Display::default() {
            gtk::style_context_add_provider_for_display(
                &display,
                &provider,
                gtk::STYLE_PROVIDER_PRIORITY_APPLICATION,
            );
        }
    });
}

fn primary_action_button(device: &BtDevice, refresh: Rc<dyn Fn()>) -> gtk::Button {
    let address = device.address.clone();
    let (label, action) = if device.connected {
        ("Disconnect", "disconnect")
    } else if device.paired {
        ("Connect", "connect")
    } else {
        ("Pair", "pair")
    };

    let btn = gtk::Button::builder()
        .label(label)
        .valign(gtk::Align::Center)
        .build();
    if action == "disconnect" {
        btn.add_css_class("destructive-action");
    } else {
        btn.add_css_class("suggested-action");
    }

    btn.connect_clicked(move |_| {
        match action {
            "disconnect" => {
                let _ = bt(&["disconnect", &address]);
            }
            "connect" => {
                let _ = bt(&["connect", &address]);
            }
            "pair" => {
                let _ = bt(&["agent", "NoInputNoOutput"]);
                let _ = bt(&["pair", &address]);
                let _ = bt(&["trust", &address]);
                let _ = bt(&["connect", &address]);
            }
            _ => {}
        }
        refresh();
    });
    btn
}

fn build_actions_popover(
    device: &BtDevice,
    parent: &gtk::Box,
    refresh: Rc<dyn Fn()>,
) -> gtk::Popover {
    let box_ = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(2)
        .margin_top(6)
        .margin_bottom(6)
        .margin_start(6)
        .margin_end(6)
        .build();

    let address = device.address.clone();
    let name = device.name.clone();

    if device.paired && !device.connected {
        box_.append(&popover_btn("Connect", false, {
            let address = address.clone();
            let refresh = refresh.clone();
            move || {
                let _ = bt(&["connect", &address]);
                refresh();
            }
        }));
    }
    if device.connected {
        box_.append(&popover_btn("Disconnect", false, {
            let address = address.clone();
            let refresh = refresh.clone();
            move || {
                let _ = bt(&["disconnect", &address]);
                refresh();
            }
        }));
    }
    if !device.paired {
        box_.append(&popover_btn("Pair", false, {
            let address = address.clone();
            let refresh = refresh.clone();
            move || {
                let _ = bt(&["agent", "NoInputNoOutput"]);
                let _ = bt(&["pair", &address]);
                let _ = bt(&["trust", &address]);
                refresh();
            }
        }));
    }

    if device.trusted {
        box_.append(&popover_btn("Untrust", false, {
            let address = address.clone();
            let refresh = refresh.clone();
            move || {
                let _ = bt(&["untrust", &address]);
                refresh();
            }
        }));
    } else {
        box_.append(&popover_btn("Trust", false, {
            let address = address.clone();
            let refresh = refresh.clone();
            move || {
                let _ = bt(&["trust", &address]);
                refresh();
            }
        }));
    }

    if device.blocked {
        box_.append(&popover_btn("Unblock", false, {
            let address = address.clone();
            let refresh = refresh.clone();
            move || {
                let _ = bt(&["unblock", &address]);
                refresh();
            }
        }));
    } else {
        box_.append(&popover_btn("Block", false, {
            let address = address.clone();
            let refresh = refresh.clone();
            move || {
                let _ = bt(&["block", &address]);
                refresh();
            }
        }));
    }

    box_.append(&popover_btn("Rename…", false, {
        let address = address.clone();
        let name = name.clone();
        let parent = parent.clone();
        let refresh = refresh.clone();
        move || {
            confirm_rename(&parent, &address, &name, refresh.clone());
        }
    }));

    box_.append(&popover_btn("Details…", false, {
        let device = device.clone();
        let parent = parent.clone();
        move || {
            show_device_info(&parent, &device);
        }
    }));

    box_.append(&gtk::Separator::new(gtk::Orientation::Horizontal));

    box_.append(&popover_btn("Remove", true, {
        let address = address.clone();
        let name = name.clone();
        let parent = parent.clone();
        let refresh = refresh.clone();
        move || {
            confirm_remove(&parent, &address, &name, refresh.clone());
        }
    }));

    let popover = gtk::Popover::builder().child(&box_).build();
    popover
}

fn popover_btn(label: &str, destructive: bool, on_click: impl Fn() + 'static) -> gtk::Button {
    let btn = gtk::Button::builder()
        .label(label)
        .has_frame(false)
        .halign(gtk::Align::Fill)
        .build();
    if let Some(child) = btn.child() {
        if let Some(lbl) = child.downcast_ref::<gtk::Label>() {
            lbl.set_xalign(0.0);
        }
    }
    if destructive {
        btn.add_css_class("destructive-action");
    }
    btn.connect_clicked(move |btn| {
        if let Some(popover) = btn
            .ancestor(gtk::Popover::static_type())
            .and_downcast::<gtk::Popover>()
        {
            popover.popdown();
        }
        on_click();
    });
    btn
}

fn confirm_rename(
    parent: &impl IsA<gtk::Widget>,
    address: &str,
    current_name: &str,
    refresh: Rc<dyn Fn()>,
) {
    let dialog = adw::AlertDialog::new(
        Some("Rename Device"),
        Some(&format!("Choose a new name for {current_name}:")),
    );

    let entry = gtk::Entry::builder().text(current_name).build();
    dialog.set_extra_child(Some(&entry));

    dialog.add_response("cancel", "Cancel");
    dialog.add_response("rename", "Rename");
    dialog.set_response_appearance("rename", adw::ResponseAppearance::Suggested);
    dialog.set_close_response("cancel");
    dialog.set_default_response(Some("rename"));

    let address = address.to_string();
    dialog.choose(Some(parent), None::<&gio::Cancellable>, move |response| {
        let name = entry.text().trim().to_string();
        if response != "rename" || name.is_empty() {
            return;
        }
        set_alias(&address, &name);
        refresh();
    });
}

fn confirm_remove(
    parent: &impl IsA<gtk::Widget>,
    address: &str,
    name: &str,
    refresh: Rc<dyn Fn()>,
) {
    let dialog = adw::AlertDialog::new(
        Some("Remove Device?"),
        Some(&format!(
            "Remove \"{name}\" ({address})? You will need to pair again to use it."
        )),
    );

    dialog.add_response("cancel", "Cancel");
    dialog.add_response("remove", "Remove");
    dialog.set_response_appearance("remove", adw::ResponseAppearance::Destructive);
    dialog.set_close_response("cancel");
    dialog.set_default_response(Some("cancel"));

    let address = address.to_string();
    dialog.choose(Some(parent), None::<&gio::Cancellable>, move |response| {
        if response != "remove" {
            return;
        }
        let _ = bt(&["remove", &address]);
        refresh();
    });
}

fn show_device_info(parent: &impl IsA<gtk::Widget>, device: &BtDevice) {
    let mut lines = vec![
        format!("Address: {}", device.address),
        format!("Type: {}", if device.address_type.is_empty() {
            "unknown"
        } else {
            &device.address_type
        }),
        format!("Paired: {}", yes_no(device.paired)),
        format!("Bonded: {}", yes_no(device.bonded)),
        format!("Trusted: {}", yes_no(device.trusted)),
        format!("Blocked: {}", yes_no(device.blocked)),
        format!("Connected: {}", yes_no(device.connected)),
    ];

    if let Some(battery) = device.battery {
        lines.push(format!("Battery: {battery}%"));
    }
    if let Some(rssi) = device.rssi {
        lines.push(format!("RSSI: {rssi} dBm"));
    }
    if !device.class.is_empty() {
        lines.push(format!("Class: {}", device.class));
    }
    if !device.modalias.is_empty() {
        lines.push(format!("Modalias: {}", device.modalias));
    }
    if !device.icon.is_empty() {
        lines.push(format!("Icon: {}", device.icon));
    }
    if !device.uuids.is_empty() {
        lines.push(String::new());
        lines.push("Services:".into());
        for uuid in &device.uuids {
            lines.push(format!("  • {uuid}"));
        }
    }

    let dialog = adw::AlertDialog::new(Some(&device.name), Some(&lines.join("\n")));
    dialog.add_response("close", "Close");
    dialog.set_close_response("close");
    dialog.set_default_response(Some("close"));
    dialog.choose(Some(parent), None::<&gio::Cancellable>, |_| {});
}

fn yes_no(v: bool) -> &'static str {
    if v {
        "yes"
    } else {
        "no"
    }
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

fn clear_box(container: &gtk::Box) {
    while let Some(child) = container.first_child() {
        container.remove(&child);
    }
}

fn resolve_device_icon(icon: &str) -> String {
    let theme = gtk::gdk::Display::default().map(|d| gtk::IconTheme::for_display(&d));
    let candidates = [
        icon,
        &format!("{icon}-symbolic"),
        "bluetooth-symbolic",
        "bluetooth-active-symbolic",
    ];
    if let Some(theme) = theme {
        for name in candidates {
            if !name.is_empty() && theme.has_icon(name) {
                return name.to_string();
            }
        }
    }
    "bluetooth-active-symbolic".to_string()
}

fn bt(args: &[&str]) -> std::process::Output {
    Command::new("bluetoothctl")
        .args(args)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output()
        .unwrap_or_else(|_| Command::new("true").output().expect("true"))
}

fn devices_fingerprint(devices: &[BtDevice]) -> String {
    let mut parts: Vec<String> = devices
        .iter()
        .map(|d| {
            format!(
                "{}|{}|{}|{}|{}|{}|{}|{:?}",
                d.address,
                d.name,
                d.paired as u8,
                d.trusted as u8,
                d.blocked as u8,
                d.connected as u8,
                d.icon,
                d.battery
            )
        })
        .collect();
    parts.sort();
    parts.join(";")
}

fn bt_stdout(args: &[&str]) -> String {
    String::from_utf8_lossy(&bt(args).stdout)
        .trim()
        .to_string()
}

fn set_powered(on: bool) {
    let _ = bt(&["power", if on { "on" } else { "off" }]);
}

fn set_alias(address: &str, alias: &str) {
    // Prefer D-Bus (works without selecting the device in bluetoothctl).
    if set_alias_dbus(address, alias) {
        return;
    }
    let script = format!("select {address}\nset-alias {alias}\n");
    let _ = Command::new("bluetoothctl")
        .stdin(Stdio::piped())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
        .and_then(|mut child| {
            use std::io::Write;
            if let Some(stdin) = child.stdin.as_mut() {
                let _ = stdin.write_all(script.as_bytes());
            }
            child.wait()
        });
}

fn set_alias_dbus(address: &str, alias: &str) -> bool {
    let path = device_object_path(address);
    Command::new("busctl")
        .args([
            "set-property",
            "org.bluez",
            &path,
            "org.bluez.Device1",
            "Alias",
            "s",
            alias,
        ])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

fn device_object_path(address: &str) -> String {
    let mac = address.replace(':', "_");
    format!("/org/bluez/hci0/dev_{mac}")
}

fn adapter_info() -> AdapterInfo {
    let output = bt_stdout(&["show"]);
    let mut info = AdapterInfo::default();
    for line in output.lines() {
        let line = line.trim();
        if let Some(rest) = line.strip_prefix("Controller ") {
            info.address = rest.split_whitespace().next().unwrap_or("").to_string();
        } else if let Some(v) = prop_bool(line, "Powered") {
            info.powered = v;
        } else if let Some(v) = prop_bool(line, "Discovering") {
            info.discovering = v;
        } else if let Some(v) = prop_str(line, "Alias").or_else(|| prop_str(line, "Name")) {
            info.name = v;
        }
    }
    info
}

fn list_devices() -> Vec<BtDevice> {
    let listing = bt_stdout(&["devices"]);
    let mut devices = Vec::new();
    let mut seen = HashMap::new();

    for line in listing.lines() {
        let line = line.trim();
        let Some(rest) = line.strip_prefix("Device ") else {
            continue;
        };
        let mut parts = rest.splitn(2, ' ');
        let Some(address) = parts.next() else {
            continue;
        };
        let name = parts.next().unwrap_or(address).to_string();
        seen.insert(address.to_string(), name);
    }

    for (address, fallback_name) in seen {
        if let Some(mut device) = device_info(&address) {
            if device.name.is_empty() {
                device.name = fallback_name;
            }
            devices.push(device);
        } else {
            devices.push(BtDevice {
                address: address.clone(),
                name: fallback_name,
                icon: String::new(),
                paired: false,
                bonded: false,
                trusted: false,
                blocked: false,
                connected: false,
                battery: None,
                rssi: None,
                address_type: String::new(),
                uuids: Vec::new(),
                modalias: String::new(),
                class: String::new(),
            });
        }
    }

    devices.sort_by(|a, b| {
        b.connected
            .cmp(&a.connected)
            .then(b.paired.cmp(&a.paired))
            .then(a.name.to_lowercase().cmp(&b.name.to_lowercase()))
    });
    devices
}

fn device_info(address: &str) -> Option<BtDevice> {
    let output = bt_stdout(&["info", address]);
    if output.is_empty() || output.contains("not available") {
        return None;
    }

    let mut device = BtDevice {
        address: address.to_string(),
        name: String::new(),
        icon: String::new(),
        paired: false,
        bonded: false,
        trusted: false,
        blocked: false,
        connected: false,
        battery: None,
        rssi: None,
        address_type: String::new(),
        uuids: Vec::new(),
        modalias: String::new(),
        class: String::new(),
    };

    for line in output.lines() {
        let line = line.trim();
        if let Some(v) = prop_str(line, "Alias").or_else(|| prop_str(line, "Name")) {
            if device.name.is_empty() || line.starts_with("Alias:") {
                device.name = v;
            }
        } else if let Some(v) = prop_str(line, "Icon") {
            device.icon = v;
        } else if let Some(v) = prop_bool(line, "Paired") {
            device.paired = v;
        } else if let Some(v) = prop_bool(line, "Bonded") {
            device.bonded = v;
        } else if let Some(v) = prop_bool(line, "Trusted") {
            device.trusted = v;
        } else if let Some(v) = prop_bool(line, "Blocked") {
            device.blocked = v;
        } else if let Some(v) = prop_bool(line, "Connected") {
            device.connected = v;
        } else if let Some(v) = prop_str(line, "Modalias") {
            device.modalias = v;
        } else if let Some(v) = prop_str(line, "Class") {
            device.class = v;
        } else if line.starts_with("Device ") {
            if line.contains("(public)") {
                device.address_type = "public".into();
            } else if line.contains("(random)") {
                device.address_type = "random".into();
            }
        } else if line.starts_with("UUID:") {
            let uuid = line.trim_start_matches("UUID:").trim();
            // "Audio Sink                (0000110b-...)"
            let pretty = if let Some((name, rest)) = uuid.rsplit_once('(') {
                let id = rest.trim_end_matches(')').trim();
                format!("{} ({id})", name.trim())
            } else {
                uuid.to_string()
            };
            device.uuids.push(pretty);
        } else if line.starts_with("Battery Percentage:") {
            device.battery = parse_battery(line);
        } else if line.starts_with("RSSI:") {
            device.rssi = parse_rssi(line);
        }
    }

    if device.name.is_empty() {
        device.name = address.to_string();
    }

    Some(device)
}

fn prop_str(line: &str, key: &str) -> Option<String> {
    let prefix = format!("{key}:");
    line.strip_prefix(&prefix)
        .map(|v| v.trim().to_string())
        .filter(|v| !v.is_empty())
}

fn prop_bool(line: &str, key: &str) -> Option<bool> {
    prop_str(line, key).map(|v| v.eq_ignore_ascii_case("yes") || v == "true")
}

fn parse_battery(line: &str) -> Option<u8> {
    // "Battery Percentage: 0x50 (80)" or "Battery Percentage: 80"
    if let Some(start) = line.rfind('(') {
        let end = line.rfind(')')?;
        return line[start + 1..end].trim().parse().ok();
    }
    line.split_whitespace().last()?.parse().ok()
}

fn parse_rssi(line: &str) -> Option<i32> {
    // "RSSI: 0xffffff9f (-97)" or "RSSI: -97"
    if let Some(start) = line.rfind('(') {
        let end = line.rfind(')')?;
        return line[start + 1..end].trim().parse().ok();
    }
    line.split_whitespace().last()?.parse().ok()
}
