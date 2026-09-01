mod sound_item;

use std::cell::RefCell;
use std::collections::HashMap;
use std::fs;
use std::os::unix::process::CommandExt;
use std::path::PathBuf;
use std::process::{Child, Command, Stdio};
use std::rc::Rc;
use std::time::Duration;

use component::{Component, spawn_background};
use gtk4::gdk;
use gtk4::gio;
use gtk4::glib;
use gtk4::pango;
use gtk4::prelude::*;
use gtk4::{self as gtk, GestureClick};
use libadwaita as adw;
use libadwaita::prelude::*;
use sound_item::{SoundboardItem, SoundboardItemData};

const AUDIO_EXTENSIONS: &[&str] = &[
    ".mp3", ".aac", ".wav", ".flac", ".ogg", ".opus", ".aiff", ".au", ".caf", ".raw",
];

struct PlaybackState {
    exclusive: HashMap<String, (Child, SoundboardItem)>,
    overlapping: HashMap<String, Vec<Child>>,
}

impl PlaybackState {
    fn new() -> Self {
        Self {
            exclusive: HashMap::new(),
            overlapping: HashMap::new(),
        }
    }
}

struct RecordingState {
    process: Option<Child>,
    popup: Option<gtk::Window>,
}

impl RecordingState {
    fn new() -> Self {
        Self {
            process: None,
            popup: None,
        }
    }
}

pub fn component() -> Component {
    Component {
        id: "soundboard",
        title: "Soundboard",
        icon: "audio-headphones-symbolic",
        build,
    }
}

fn build() -> gtk::Widget {
    let store = gio::ListStore::new::<SoundboardItem>();

    let query = Rc::new(RefCell::new(String::new()));
    let filter = gtk::CustomFilter::new(glib::clone!(
        #[strong]
        query,
        move |obj| {
            let q = query.borrow();
            if q.is_empty() {
                return true;
            }
            obj.downcast_ref::<SoundboardItem>()
                .map(|item| item.display_name().to_lowercase().contains(q.as_str()))
                .unwrap_or(false)
        }
    ));

    let filter_model = gtk::FilterListModel::new(Some(store.clone()), Some(filter.clone()));
    let selection = gtk::SingleSelection::new(Some(filter_model));
    if selection.n_items() > 0 {
        selection.set_selected(0);
    }

    let search = gtk::SearchEntry::builder().hexpand(true).build();
    let playback = Rc::new(RefCell::new(PlaybackState::new()));
    let recording = Rc::new(RefCell::new(RecordingState::new()));

    let empty = component::empty_list_label("No sounds");
    empty.set_visible(false);
    let loading = gtk::Spinner::builder()
        .margin_top(12)
        .halign(gtk::Align::Center)
        .build();
    loading.start();

    let refresh: Rc<dyn Fn()> = Rc::new(glib::clone!(
        #[weak]
        store,
        #[weak]
        selection,
        #[weak]
        search,
        #[weak]
        empty,
        #[weak]
        loading,
        #[strong]
        playback,
        move || {
            refresh_ui(&store, &selection, &search, &empty, &loading, &playback);
        }
    ));

    let factory = gtk::SignalListItemFactory::new();
    factory.connect_setup(glib::clone!(
        #[strong]
        playback,
        #[strong]
        refresh,
        #[weak]
        selection,
        move |_, item| {
            let list_item = item
                .downcast_ref::<gtk::ListItem>()
                .expect("ListItem in setup");

            let row = gtk::Box::builder()
                .orientation(gtk::Orientation::Horizontal)
                .spacing(12)
                .margin_top(6)
                .margin_bottom(6)
                .margin_start(12)
                .margin_end(12)
                .build();

            let icon = gtk::Image::from_icon_name("audio-x-generic-symbolic");
            let label = gtk::Label::builder()
                .xalign(0.0)
                .hexpand(true)
                .ellipsize(pango::EllipsizeMode::End)
                .build();
            let spinner = gtk::Spinner::new();
            spinner.set_visible(false);

            let btn_toggle = gtk::Button::from_icon_name("media-playback-start-symbolic");
            btn_toggle.set_tooltip_text(Some("Play Sound"));

            let btn_overlap = gtk::Button::from_icon_name("media-playlist-repeat-symbolic");
            btn_overlap.set_tooltip_text(Some("Play Overlapping"));

            let btn_rename = gtk::Button::from_icon_name("document-edit-symbolic");
            btn_rename.set_tooltip_text(Some("Rename Sound"));

            let btn_delete = gtk::Button::from_icon_name("user-trash-symbolic");
            btn_delete.set_tooltip_text(Some("Delete Sound"));
            btn_delete.add_css_class("destructive-action");

            let btn_box = gtk::Box::builder()
                .orientation(gtk::Orientation::Horizontal)
                .spacing(4)
                .build();
            btn_box.append(&btn_toggle);
            btn_box.append(&btn_overlap);
            btn_box.append(&btn_rename);
            btn_box.append(&btn_delete);

            row.append(&icon);
            row.append(&label);
            row.append(&spinner);
            row.append(&btn_box);
            list_item.set_child(Some(&row));

            let gesture = GestureClick::new();
            gesture.connect_released(glib::clone!(
                #[weak]
                list_item,
                #[weak]
                selection,
                move |_, n_press, _, _| {
                    if n_press != 1 {
                        return;
                    }
                    let position = list_item.position();
                    if position != gtk::INVALID_LIST_POSITION {
                        selection.set_selected(position);
                    }
                }
            ));
            row.add_controller(gesture);

            btn_toggle.connect_clicked(glib::clone!(
                #[weak]
                list_item,
                #[strong]
                playback,
                move |_| {
                    if let Some(item) = list_item.item().and_downcast::<SoundboardItem>() {
                        toggle_item(&playback, &item);
                    }
                }
            ));

            btn_overlap.connect_clicked(glib::clone!(
                #[weak]
                list_item,
                #[strong]
                playback,
                move |_| {
                    if let Some(item) = list_item.item().and_downcast::<SoundboardItem>() {
                        play_overlapping(&playback, &item);
                    }
                }
            ));

            btn_rename.connect_clicked(glib::clone!(
                #[weak]
                list_item,
                #[strong]
                refresh,
                move |btn| {
                    if let Some(item) = list_item.item().and_downcast::<SoundboardItem>() {
                        confirm_rename(btn, &item, refresh.clone());
                    }
                }
            ));

            btn_delete.connect_clicked(glib::clone!(
                #[weak]
                list_item,
                #[strong]
                refresh,
                #[strong]
                playback,
                move |btn| {
                    if let Some(item) = list_item.item().and_downcast::<SoundboardItem>() {
                        confirm_delete(btn, &item, &playback, refresh.clone());
                    }
                }
            ));
        }
    ));

    factory.connect_bind(move |_, item| {
        let list_item = item
            .downcast_ref::<gtk::ListItem>()
            .expect("ListItem in bind");
        let Some(sound) = list_item.item().and_downcast::<SoundboardItem>() else {
            return;
        };
        let Some(row) = list_item.child().and_downcast::<gtk::Box>() else {
            return;
        };

        let label = row
            .first_child()
            .and_then(|c| c.next_sibling())
            .and_downcast::<gtk::Label>()
            .expect("label");
        let spinner = label
            .next_sibling()
            .and_downcast::<gtk::Spinner>()
            .expect("spinner");
        let btn_box = spinner
            .next_sibling()
            .and_downcast::<gtk::Box>()
            .expect("btn box");
        let btn_toggle = btn_box
            .first_child()
            .and_downcast::<gtk::Button>()
            .expect("toggle button");

        label.set_text(sound.display_name());
        update_playback_widgets(&sound, &spinner, &btn_toggle);

        let handler = sound.connect_is_playing_notify(glib::clone!(
            #[weak]
            spinner,
            #[weak]
            btn_toggle,
            move |sound| {
                update_playback_widgets(sound, &spinner, &btn_toggle);
            }
        ));
        unsafe {
            list_item.set_data("is-playing-handler", handler);
        }
    });

    factory.connect_unbind(move |_, item| {
        let list_item = item
            .downcast_ref::<gtk::ListItem>()
            .expect("ListItem in unbind");
        let handler =
            unsafe { list_item.steal_data::<glib::SignalHandlerId>("is-playing-handler") };
        if let (Some(handler), Some(sound)) =
            (handler, list_item.item().and_downcast::<SoundboardItem>())
        {
            sound.disconnect(handler);
        }
    });

    let view = gtk::ListView::builder()
        .model(&selection)
        .factory(&factory)
        .single_click_activate(false)
        .css_classes(["navigation-sidebar"])
        .build();

    search.connect_search_changed(glib::clone!(
        #[strong]
        query,
        #[weak]
        filter,
        #[weak]
        selection,
        #[weak]
        search,
        #[weak]
        empty,
        #[weak]
        loading,
        move |entry| {
            *query.borrow_mut() = entry.text().to_lowercase();
            filter.changed(gtk::FilterChange::Different);
            if selection.n_items() > 0 {
                selection.set_selected(0);
            }
            component::update_list_empty_state(&selection, &empty, &loading);
            if !entry.has_focus() {
                glib::idle_add_local_once(glib::clone!(
                    #[weak]
                    search,
                    move || {
                        search.grab_focus();
                        search.set_position(-1);
                    }
                ));
            }
        }
    ));

    search.connect_activate(glib::clone!(
        #[weak]
        selection,
        #[strong]
        playback,
        move |_| {
            play_focused(&selection, &playback);
        }
    ));

    let key_controller = gtk::EventControllerKey::new();
    key_controller.connect_key_pressed(glib::clone!(
        #[weak]
        selection,
        #[weak]
        view,
        #[weak]
        search,
        #[upgrade_or]
        glib::Propagation::Proceed,
        move |_, key, _, _| handle_nav_key(key, &selection, &view, &search)
    ));
    search.add_controller(key_controller);

    let scrolled = gtk::ScrolledWindow::builder()
        .child(&view)
        .vexpand(true)
        .build();

    let list_container = gtk::Overlay::new();
    list_container.set_child(Some(&scrolled));
    list_container.add_overlay(&empty);

    let btn_stop_all = gtk::Button::with_label("Stop All Sounds");
    btn_stop_all.add_css_class("destructive-action");
    btn_stop_all.connect_clicked(glib::clone!(
        #[strong]
        playback,
        #[weak]
        store,
        move |_| {
            stop_all(&playback, &store);
        }
    ));

    let btn_record = gtk::Button::with_label("Record");
    btn_record.connect_clicked(glib::clone!(
        #[strong]
        recording,
        move |btn| {
            start_recording(btn, &recording);
        }
    ));

    let btn_save_rec = gtk::Button::with_label("Save Record");
    btn_save_rec.connect_clicked(glib::clone!(
        #[strong]
        refresh,
        move |btn| {
            confirm_save_recording(btn, refresh.clone());
        }
    ));

    let btn_play_rec = gtk::Button::with_label("Play Record");
    btn_play_rec.connect_clicked(|_| {
        play_last_recording();
    });

    let spacer = gtk::Box::builder().hexpand(true).build();

    let btn_play_focused = gtk::Button::with_label("Play Focused");
    btn_play_focused.add_css_class("suggested-action");
    btn_play_focused.connect_clicked(glib::clone!(
        #[weak]
        selection,
        #[strong]
        playback,
        move |_| {
            play_focused(&selection, &playback);
        }
    ));

    let footer = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(6)
        .build();
    footer.append(&btn_stop_all);
    footer.append(&btn_record);
    footer.append(&btn_save_rec);
    footer.append(&btn_play_rec);
    footer.append(&spacer);
    footer.append(&btn_play_focused);

    let page = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(12)
        .margin_top(6)
        .margin_bottom(6)
        .margin_start(6)
        .margin_end(6)
        .build();

    page.append(&search);
    page.append(&list_container);
    page.append(&footer);

    search.set_key_capture_widget(Some(&page));

    page.connect_map(glib::clone!(
        #[weak]
        search,
        move |_| {
            search.grab_focus();
            search.set_position(-1);
        }
    ));

    page.prepend(&loading);

    spawn_background(
        load_sound_item_data,
        glib::clone!(
            #[strong]
            store,
            #[weak]
            selection,
            #[weak]
            loading,
            #[weak]
            empty,
            move |items| {
                for data in items {
                    store.append(&SoundboardItem::from_data(&data));
                }
                if selection.n_items() > 0 {
                    selection.set_selected(0);
                }
                loading.stop();
                loading.set_visible(false);
                component::update_list_empty_state(&selection, &empty, &loading);
            }
        ),
    );

    glib::timeout_add_local(
        Duration::from_millis(250),
        glib::clone!(
            #[strong]
            playback,
            #[weak]
            store,
            #[upgrade_or]
            glib::ControlFlow::Break,
            move || {
                check_playing_sounds(&playback, &store);
                glib::ControlFlow::Continue
            }
        ),
    );

    page.upcast()
}

fn handle_nav_key(
    key: gdk::Key,
    selection: &gtk::SingleSelection,
    view: &gtk::ListView,
    search: &gtk::SearchEntry,
) -> glib::Propagation {
    if key == gdk::Key::Down {
        move_selection(selection, view, 1);
        return glib::Propagation::Stop;
    }
    if key == gdk::Key::Up {
        move_selection(selection, view, -1);
        return glib::Propagation::Stop;
    }
    if key == gdk::Key::Tab || key == gdk::Key::ISO_Left_Tab {
        let position = selection.selected();
        if position != gtk::INVALID_LIST_POSITION
            && selection.n_items() > 0
            && let Some(item) = selection.item(position).and_downcast::<SoundboardItem>()
        {
            search.set_text(item.display_name());
            search.set_position(-1);
            glib::idle_add_local_once(glib::clone!(
                #[weak]
                search,
                move || {
                    search.grab_focus();
                    search.set_position(-1);
                }
            ));
        }
        return glib::Propagation::Stop;
    }
    glib::Propagation::Proceed
}

fn move_selection(selection: &gtk::SingleSelection, view: &gtk::ListView, delta: i32) {
    let n = selection.n_items();
    if n == 0 {
        return;
    }

    let current = selection.selected();
    let next = if current == gtk::INVALID_LIST_POSITION {
        if delta > 0 { 0 } else { n - 1 }
    } else {
        (current as i32 + delta).clamp(0, n as i32 - 1) as u32
    };

    selection.set_selected(next);
    view.scroll_to(next, gtk::ListScrollFlags::SELECT, None);
}

fn update_playback_widgets(item: &SoundboardItem, spinner: &gtk::Spinner, btn: &gtk::Button) {
    if item.is_playing() {
        spinner.set_visible(true);
        spinner.start();
        btn.set_icon_name("media-playback-stop-symbolic");
        btn.set_tooltip_text(Some("Stop Sound"));
    } else {
        spinner.stop();
        spinner.set_visible(false);
        btn.set_icon_name("media-playback-start-symbolic");
        btn.set_tooltip_text(Some("Play Sound"));
    }
}

fn update_item_playing_state(playback: &RefCell<PlaybackState>, item: &SoundboardItem) {
    let state = playback.borrow();
    let path = item.file_path();
    let has_exclusive = state.exclusive.contains_key(path);
    let has_overlapping = state
        .overlapping
        .get(path)
        .map(|procs| !procs.is_empty())
        .unwrap_or(false);
    drop(state);
    item.set_is_playing(has_exclusive || has_overlapping);
}

fn check_playing_sounds(playback: &Rc<RefCell<PlaybackState>>, store: &gio::ListStore) {
    let mut state = playback.borrow_mut();

    let finished: Vec<String> = state
        .exclusive
        .iter_mut()
        .filter_map(|(path, (child, _))| match child.try_wait() {
            Ok(Some(_)) => Some(path.clone()),
            _ => None,
        })
        .collect();

    let mut finished_items = Vec::new();
    for path in finished {
        if let Some((_, item)) = state.exclusive.remove(&path) {
            finished_items.push(item);
        }
    }

    let mut overlap_changed = Vec::new();
    for (path, procs) in state.overlapping.iter_mut() {
        let before = procs.len();
        procs.retain_mut(|child| !matches!(child.try_wait(), Ok(Some(_))));
        if procs.len() != before {
            overlap_changed.push(path.clone());
        }
    }
    state.overlapping.retain(|_, procs| !procs.is_empty());
    drop(state);

    for item in finished_items {
        update_item_playing_state(playback, &item);
    }

    for i in 0..store.n_items() {
        if let Some(item) = store.item(i).and_downcast::<SoundboardItem>()
            && overlap_changed.iter().any(|p| p == item.file_path())
        {
            update_item_playing_state(playback, &item);
        }
    }
}

fn play_command(path: &str) -> String {
    let quoted = shell_quote(path);
    format!(
        "paplay --device='SoundboardSink' --volume=65536 {quoted} & paplay --device=\"$(pactl get-default-sink)\" --volume=32768 {quoted} & wait"
    )
}

fn shell_quote(s: &str) -> String {
    format!("'{}'", s.replace('\'', "'\\''"))
}

fn spawn_play(path: &str) -> Option<Child> {
    match Command::new("sh")
        .args(["-c", &play_command(path)])
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .process_group(0)
        .spawn()
    {
        Ok(child) => Some(child),
        Err(err) => {
            eprintln!("Error executing audio command: {err}");
            None
        }
    }
}

fn kill_process_group(child: &Child) {
    let pid = child.id();
    let _ = Command::new("kill")
        .args(["-TERM", &format!("-{pid}")])
        .status();
}

fn play_audio_file(playback: &Rc<RefCell<PlaybackState>>, item: &SoundboardItem) {
    let path = item.file_path().to_string();
    {
        let state = playback.borrow();
        if state.exclusive.contains_key(&path) {
            drop(state);
            stop_audio_file(playback, item);
        }
    }

    let Some(child) = spawn_play(&path) else {
        return;
    };

    playback
        .borrow_mut()
        .exclusive
        .insert(path, (child, item.clone()));
    update_item_playing_state(playback, item);
}

fn stop_audio_file(playback: &Rc<RefCell<PlaybackState>>, item: &SoundboardItem) {
    let path = item.file_path().to_string();
    if let Some((child, _)) = playback.borrow_mut().exclusive.remove(&path) {
        kill_process_group(&child);
        let mut child = child;
        let _ = child.wait();
    }
    update_item_playing_state(playback, item);
}

fn play_overlapping(playback: &Rc<RefCell<PlaybackState>>, item: &SoundboardItem) {
    let path = item.file_path().to_string();
    let Some(child) = spawn_play(&path) else {
        return;
    };

    playback
        .borrow_mut()
        .overlapping
        .entry(path)
        .or_default()
        .push(child);
    update_item_playing_state(playback, item);
}

fn stop_overlapping(playback: &Rc<RefCell<PlaybackState>>, item: &SoundboardItem) {
    let path = item.file_path().to_string();
    if let Some(procs) = playback.borrow_mut().overlapping.remove(&path) {
        for child in procs {
            kill_process_group(&child);
            let mut child = child;
            let _ = child.wait();
        }
    }
    update_item_playing_state(playback, item);
}

fn toggle_item(playback: &Rc<RefCell<PlaybackState>>, item: &SoundboardItem) {
    if item.is_playing() {
        stop_audio_file(playback, item);
        stop_overlapping(playback, item);
    } else {
        play_audio_file(playback, item);
    }
}

fn play_focused(selection: &gtk::SingleSelection, playback: &Rc<RefCell<PlaybackState>>) {
    let mut position = selection.selected();
    if selection.n_items() == 0 {
        return;
    }
    if position == gtk::INVALID_LIST_POSITION || position >= selection.n_items() {
        position = 0;
    }
    if let Some(item) = selection.item(position).and_downcast::<SoundboardItem>() {
        play_audio_file(playback, &item);
    }
}

fn stop_all(playback: &Rc<RefCell<PlaybackState>>, store: &gio::ListStore) {
    let mut state = playback.borrow_mut();

    for (_, (child, _)) in state.exclusive.drain() {
        kill_process_group(&child);
        let mut child = child;
        let _ = child.wait();
    }

    for (_, procs) in state.overlapping.drain() {
        for child in procs {
            kill_process_group(&child);
            let mut child = child;
            let _ = child.wait();
        }
    }
    drop(state);

    for i in 0..store.n_items() {
        if let Some(item) = store.item(i).and_downcast::<SoundboardItem>() {
            item.set_is_playing(false);
        }
    }
}

fn record_path() -> PathBuf {
    dirs_soundboard().join("custom").join("record.wav")
}

fn dirs_soundboard() -> PathBuf {
    let dir = glib::home_dir().join(".soundboard");
    let _ = fs::create_dir_all(dir.join("custom"));
    dir
}

fn start_recording(parent: &impl IsA<gtk::Widget>, recording: &Rc<RefCell<RecordingState>>) {
    {
        let state = recording.borrow();
        if state.process.is_some() {
            return;
        }
    }

    let path = record_path();
    let child = match Command::new("pw-record")
        .arg(&path)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .spawn()
    {
        Ok(child) => child,
        Err(err) => {
            eprintln!("Failed to start pw-record: {err}");
            return;
        }
    };

    recording.borrow_mut().process = Some(child);
    open_recording_popup(parent, recording);
}

fn open_recording_popup(parent: &impl IsA<gtk::Widget>, recording: &Rc<RefCell<RecordingState>>) {
    let transient = parent.root().and_downcast::<gtk::Window>();

    let popup = gtk::Window::builder()
        .title("Recording Manager")
        .modal(true)
        .destroy_with_parent(true)
        .default_width(260)
        .default_height(130)
        .build();

    if let Some(ref transient) = transient {
        popup.set_transient_for(Some(transient));
    }

    let vbox = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(16)
        .margin_top(16)
        .margin_bottom(16)
        .margin_start(16)
        .margin_end(16)
        .build();

    let label = gtk::Label::builder()
        .label("Audio capture active...")
        .halign(gtk::Align::Center)
        .build();

    let btn_stop = gtk::Button::with_label("Stop Recording");
    btn_stop.add_css_class("destructive-action");
    btn_stop.set_halign(gtk::Align::Center);
    btn_stop.connect_clicked(glib::clone!(
        #[strong]
        recording,
        move |_| {
            stop_recording(&recording);
        }
    ));

    vbox.append(&label);
    vbox.append(&btn_stop);
    popup.set_child(Some(&vbox));

    let key_ctrl = gtk::EventControllerKey::new();
    key_ctrl.connect_key_pressed(glib::clone!(
        #[strong]
        recording,
        move |_, key, _, _| {
            if key == gdk::Key::Escape {
                stop_recording(&recording);
                return glib::Propagation::Stop;
            }
            glib::Propagation::Proceed
        }
    ));
    popup.add_controller(key_ctrl);

    popup.connect_close_request(glib::clone!(
        #[strong]
        recording,
        move |_| {
            stop_recording(&recording);
            glib::Propagation::Proceed
        }
    ));

    recording.borrow_mut().popup = Some(popup.clone());
    popup.present();
}

fn stop_recording(recording: &Rc<RefCell<RecordingState>>) {
    let mut state = recording.borrow_mut();

    if let Some(mut child) = state.process.take()
        && child.try_wait().ok().flatten().is_none()
    {
        let _ = child.kill();
        let _ = child.wait();
    }

    if let Some(popup) = state.popup.take() {
        popup.destroy();
    }
}

fn play_last_recording() {
    let path = record_path();
    if !path.exists() {
        return;
    }
    let _ = spawn_play(&path.to_string_lossy());
}

fn confirm_save_recording(parent: &impl IsA<gtk::Widget>, refresh: Rc<dyn Fn()>) {
    if !record_path().exists() {
        return;
    }

    let dialog = adw::AlertDialog::new(
        Some("Save Captured Audio"),
        Some("Enter a clean system tag layout name for this sound entry:"),
    );

    let entry = gtk::Entry::builder()
        .placeholder_text("e.g., epic airhorn")
        .build();
    dialog.set_extra_child(Some(&entry));

    dialog.add_response("cancel", "Cancel");
    dialog.add_response("save", "Save Sound");
    dialog.set_response_appearance("save", adw::ResponseAppearance::Suggested);
    dialog.set_close_response("cancel");
    dialog.set_default_response(Some("cancel"));

    dialog.choose(Some(parent), None::<&gio::Cancellable>, move |response| {
        let name = entry.text().trim().to_string();
        if response != "save" || name.is_empty() {
            return;
        }

        let safe_name = sanitize_name(&name);
        let dest = dirs_soundboard().join(format!("{safe_name}.wav"));
        if dest.exists() {
            return;
        }

        if let Err(err) = fs::copy(record_path(), &dest) {
            eprintln!("Error copying recording: {err}");
            return;
        }
        refresh();
    });
}

fn confirm_rename(parent: &impl IsA<gtk::Widget>, item: &SoundboardItem, refresh: Rc<dyn Fn()>) {
    let source = PathBuf::from(item.file_path());
    let dialog = adw::AlertDialog::new(
        Some("Rename Sound Byte"),
        Some(&format!(
            "Provide an updated track alias for '{}':",
            item.display_name()
        )),
    );

    let entry = gtk::Entry::builder().text(item.display_name()).build();
    dialog.set_extra_child(Some(&entry));

    dialog.add_response("cancel", "Cancel");
    dialog.add_response("rename", "Apply Rename");
    dialog.set_response_appearance("rename", adw::ResponseAppearance::Suggested);
    dialog.set_close_response("cancel");
    dialog.set_default_response(Some("cancel"));

    dialog.choose(Some(parent), None::<&gio::Cancellable>, move |response| {
        let name = entry.text().trim().to_string();
        if response != "rename" || name.is_empty() {
            return;
        }

        let safe_name = sanitize_name(&name);
        let dest = source.with_file_name(format!(
            "{}{}",
            safe_name,
            source
                .extension()
                .and_then(|e| e.to_str())
                .map(|e| format!(".{e}"))
                .unwrap_or_default()
        ));

        if let Err(err) = fs::rename(&source, &dest) {
            eprintln!("Error renaming sound: {err}");
            return;
        }
        refresh();
    });
}

fn confirm_delete(
    parent: &impl IsA<gtk::Widget>,
    item: &SoundboardItem,
    playback: &Rc<RefCell<PlaybackState>>,
    refresh: Rc<dyn Fn()>,
) {
    let dialog = adw::AlertDialog::new(
        Some("Wipe Audio Sample?"),
        Some(&format!(
            "Are you sure you want to completely erase '{}'? This cannot be undone.",
            item.display_name()
        )),
    );

    dialog.add_response("cancel", "Cancel");
    dialog.add_response("delete", "Delete Sound");
    dialog.set_response_appearance("delete", adw::ResponseAppearance::Destructive);
    dialog.set_close_response("cancel");
    dialog.set_default_response(Some("cancel"));

    let item = item.clone();
    let playback = playback.clone();
    dialog.choose(Some(parent), None::<&gio::Cancellable>, move |response| {
        if response != "delete" {
            return;
        }
        stop_audio_file(&playback, &item);
        stop_overlapping(&playback, &item);
        if let Err(err) = fs::remove_file(item.file_path()) {
            eprintln!("Error deleting sound: {err}");
            return;
        }
        refresh();
    });
}

fn sanitize_name(name: &str) -> String {
    name.replace(' ', "-")
        .chars()
        .filter(|c| c.is_ascii_alphanumeric() || matches!(c, '_' | '-' | ' '))
        .collect::<String>()
        .to_lowercase()
}

fn display_name_from_stem(stem: &str) -> String {
    let name = stem.replace(['-', '_'], " ");
    let trimmed = name.trim();
    let mut chars = trimmed.chars();
    match chars.next() {
        None => String::new(),
        Some(first) => first.to_uppercase().to_string() + &chars.as_str().to_lowercase(),
    }
}

fn refresh_ui(
    store: &gio::ListStore,
    selection: &gtk::SingleSelection,
    search: &gtk::SearchEntry,
    empty: &gtk::Label,
    loading: &gtk::Spinner,
    playback: &Rc<RefCell<PlaybackState>>,
) {
    spawn_background(
        load_sound_item_data,
        glib::clone!(
            #[strong]
            store,
            #[strong]
            playback,
            #[weak]
            selection,
            #[weak]
            search,
            #[weak]
            empty,
            #[weak]
            loading,
            move |items| {
                store.remove_all();
                for data in &items {
                    let item = SoundboardItem::from_data(data);
                    store.append(&item);
                    update_item_playing_state(&playback, &item);
                }
                if selection.n_items() > 0 {
                    selection.set_selected(0);
                }
                component::update_list_empty_state(&selection, &empty, &loading);
                glib::idle_add_local_once(glib::clone!(
                    #[weak]
                    search,
                    move || {
                        search.grab_focus();
                        search.set_position(-1);
                    }
                ));
            }
        ),
    );
}

fn load_sound_item_data() -> Vec<SoundboardItemData> {
    let dir = dirs_soundboard();
    let mut items = Vec::new();

    let Ok(entries) = fs::read_dir(&dir) else {
        return items;
    };

    for entry in entries.flatten() {
        let path = entry.path();
        if !path.is_file() {
            continue;
        }
        let ext = path
            .extension()
            .and_then(|e| e.to_str())
            .map(|e| format!(".{}", e.to_lowercase()))
            .unwrap_or_default();
        if !AUDIO_EXTENSIONS.contains(&ext.as_str()) {
            continue;
        }

        let stem = path
            .file_stem()
            .and_then(|s| s.to_str())
            .unwrap_or_default();
        let display_name = display_name_from_stem(stem);
        items.push(SoundboardItemData {
            display_name,
            file_path: path.to_string_lossy().into_owned(),
        });
    }

    items.sort_by_key(|item| item.display_name.to_lowercase());
    items
}
