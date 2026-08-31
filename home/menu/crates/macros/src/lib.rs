use std::collections::HashMap;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::{Duration, Instant};

use component::Component;
use evdev::uinput::VirtualDevice;
use evdev::{AttributeSet, EventType, InputEvent, KeyCode};
use gtk4::gdk;
use gtk4::glib;
use gtk4::glib::SendWeakRef;
use gtk4::prelude::*;
use gtk4::{self as gtk};
use libadwaita as adw;

struct DeviceState {
    device: Mutex<Option<VirtualDevice>>,
    ready: AtomicBool,
    running: AtomicBool,
}

#[derive(Clone)]
struct KbInfo {
    action_type: u32,
    text: String,
    key: KeyCode,
    shift: bool,
    ctrl: bool,
    alt: bool,
    super_key: bool,
}

const DELAY_SECONDS: [u64; 4] = [0, 1, 3, 5];

const SPECIAL_KEYS: &[(&str, KeyCode)] = &[
    ("Return (Enter)", KeyCode::KEY_ENTER),
    ("Tab", KeyCode::KEY_TAB),
    ("Space", KeyCode::KEY_SPACE),
    ("Backspace", KeyCode::KEY_BACKSPACE),
    ("Escape", KeyCode::KEY_ESC),
    ("Arrow Up", KeyCode::KEY_UP),
    ("Arrow Down", KeyCode::KEY_DOWN),
    ("Arrow Left", KeyCode::KEY_LEFT),
    ("Arrow Right", KeyCode::KEY_RIGHT),
    ("Home", KeyCode::KEY_HOME),
    ("End", KeyCode::KEY_END),
    ("Page Up", KeyCode::KEY_PAGEUP),
    ("Page Down", KeyCode::KEY_PAGEDOWN),
    ("Insert", KeyCode::KEY_INSERT),
    ("Delete", KeyCode::KEY_DELETE),
    ("F1", KeyCode::KEY_F1),
    ("F2", KeyCode::KEY_F2),
    ("F3", KeyCode::KEY_F3),
    ("F4", KeyCode::KEY_F4),
    ("F5", KeyCode::KEY_F5),
    ("F6", KeyCode::KEY_F6),
    ("F7", KeyCode::KEY_F7),
    ("F8", KeyCode::KEY_F8),
    ("F9", KeyCode::KEY_F9),
    ("F10", KeyCode::KEY_F10),
    ("F11", KeyCode::KEY_F11),
    ("F12", KeyCode::KEY_F12),
];

pub fn component() -> Component {
    Component {
        id: "macros",
        title: "Macros",
        icon: "input-keyboard-symbolic",
        build: build,
    }
}

fn build() -> gtk::Widget {
    let state = Arc::new(DeviceState {
        device: Mutex::new(None),
        ready: AtomicBool::new(false),
        running: AtomicBool::new(false),
    });

    let delay_dropdown =
        gtk::DropDown::from_strings(&["0 seconds", "1 second", "3 seconds", "5 seconds"]);

    let interval_spin = gtk::SpinButton::with_range(0.0, 10000.0, 10.0);
    interval_spin.set_value(100.0);

    let interval_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(5)
        .valign(gtk::Align::Center)
        .build();
    interval_box.append(&gtk::Label::new(Some("Interval:")));
    interval_box.append(&interval_spin);
    interval_box.append(&gtk::Label::new(Some("ms")));

    let start_btn = gtk::Button::from_icon_name("media-playback-start-symbolic");
    start_btn.set_tooltip_text(Some("Start (F5)"));
    start_btn.set_sensitive(false);
    start_btn.add_css_class("suggested-action");
    start_btn.set_valign(gtk::Align::Center);

    let stop_btn = gtk::Button::from_icon_name("media-playback-stop-symbolic");
    stop_btn.set_tooltip_text(Some("Stop (F6)"));
    stop_btn.add_css_class("destructive-action");
    stop_btn.set_valign(gtk::Align::Center);
    stop_btn.set_sensitive(false);

    let btn_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(5)
        .build();
    btn_box.append(&start_btn);
    btn_box.append(&stop_btn);

    let header = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(12)
        .margin_start(6)
        .margin_end(6)
        .margin_top(6)
        .build();
    header.append(&delay_dropdown);
    header.append(&interval_box);
    let spacer = gtk::Box::builder().hexpand(true).build();
    header.append(&spacer);
    header.append(&btn_box);

    let stack = adw::ViewStack::new();
    stack.set_vexpand(true);

    let mouse_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(15)
        .halign(gtk::Align::Center)
        .valign(gtk::Align::Center)
        .build();
    let mouse_btn_select = gtk::DropDown::from_strings(&["Left", "Middle", "Right"]);
    mouse_box.append(&gtk::Label::new(Some("Select Mouse Button:")));
    mouse_box.append(&mouse_btn_select);
    stack.add_titled_with_icon(&mouse_box, Some("mouse"), "Mouse", "input-mouse-symbolic");

    let kb_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(15)
        .halign(gtk::Align::Center)
        .valign(gtk::Align::Center)
        .build();

    let mode_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(10)
        .build();
    mode_box.append(&gtk::Label::new(Some("Action:")));
    let kb_action_select = gtk::DropDown::from_strings(&["Type Text", "Press Special Key"]);
    mode_box.append(&kb_action_select);
    kb_box.append(&mode_box);

    let kb_stack = gtk::Stack::new();

    let text_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(10)
        .build();
    text_box.append(&gtk::Label::new(Some("Text:")));
    let key_entry = gtk::Entry::builder()
        .placeholder_text("e.g., Hello World")
        .width_chars(20)
        .build();
    text_box.append(&key_entry);
    kb_stack.add_named(&text_box, Some("text"));

    let special_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(10)
        .build();
    special_box.append(&gtk::Label::new(Some("Key:")));
    let special_names: Vec<&str> = SPECIAL_KEYS.iter().map(|(name, _)| *name).collect();
    let special_key_select = gtk::DropDown::from_strings(&special_names);
    special_box.append(&special_key_select);
    kb_stack.add_named(&special_box, Some("special"));

    kb_box.append(&kb_stack);

    let shift = gtk::CheckButton::with_label("Shift");
    let ctrl = gtk::CheckButton::with_label("Ctrl");
    let alt = gtk::CheckButton::with_label("Alt");
    let super_key = gtk::CheckButton::with_label("Super");

    let mod_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(15)
        .build();
    mod_box.append(&shift);
    mod_box.append(&ctrl);
    mod_box.append(&alt);
    mod_box.append(&super_key);
    kb_box.append(&mod_box);

    stack.add_titled_with_icon(&kb_box, Some("kb"), "Keyboard", "input-keyboard-symbolic");

    kb_action_select.connect_selected_notify(glib::clone!(
        #[weak]
        kb_stack,
        move |dropdown| {
            if dropdown.selected() == 0 {
                kb_stack.set_visible_child_name("text");
            } else {
                kb_stack.set_visible_child_name("special");
            }
        }
    ));

    let switcher = adw::ViewSwitcher::builder()
        .stack(&stack)
        .halign(gtk::Align::Center)
        .margin_top(15)
        .margin_bottom(15)
        .build();

    let dur_mins = gtk::SpinButton::with_range(0.0, 60.0, 1.0);
    let dur_secs = gtk::SpinButton::with_range(0.0, 59.0, 1.0);
    dur_secs.set_value(5.0);

    let duration_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(10)
        .halign(gtk::Align::Center)
        .margin_bottom(20)
        .build();
    duration_box.append(&gtk::Label::new(Some("Duration of automation:")));
    duration_box.append(&dur_mins);
    duration_box.append(&gtk::Label::new(Some("mins")));
    duration_box.append(&dur_secs);
    duration_box.append(&gtk::Label::new(Some("secs")));

    let page = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(0)
        .build();
    page.append(&header);
    page.append(&switcher);
    page.append(&stack);
    page.append(&duration_box);

    start_btn.connect_clicked(glib::clone!(
        #[strong]
        state,
        #[weak]
        start_btn,
        #[weak]
        stop_btn,
        #[weak]
        stack,
        #[weak]
        delay_dropdown,
        #[weak]
        interval_spin,
        #[weak]
        dur_mins,
        #[weak]
        dur_secs,
        #[weak]
        mouse_btn_select,
        #[weak]
        kb_action_select,
        #[weak]
        key_entry,
        #[weak]
        special_key_select,
        #[weak]
        shift,
        #[weak]
        ctrl,
        #[weak]
        alt,
        #[weak]
        super_key,
        move |_| {
            if state.running.load(Ordering::SeqCst) {
                return;
            }
            if !state.ready.load(Ordering::SeqCst) {
                return;
            }

            start_btn.set_sensitive(false);
            stop_btn.set_sensitive(true);

            let mode = stack
                .visible_child_name()
                .unwrap_or_else(|| "mouse".into())
                .to_string();
            let start_delay = DELAY_SECONDS
                .get(delay_dropdown.selected() as usize)
                .copied()
                .unwrap_or(0);
            let interval_ms = interval_spin.value();
            let duration_secs = dur_mins.value() * 60.0 + dur_secs.value();
            let mouse_btn = mouse_btn_select.selected();
            let special_idx = special_key_select.selected() as usize;
            let special_key = SPECIAL_KEYS
                .get(special_idx)
                .map(|(_, key)| *key)
                .unwrap_or(KeyCode::KEY_ENTER);

            let kb_info = KbInfo {
                action_type: kb_action_select.selected(),
                text: key_entry.text().to_string(),
                key: special_key,
                shift: shift.is_active(),
                ctrl: ctrl.is_active(),
                alt: alt.is_active(),
                super_key: super_key.is_active(),
            };

            start_automation(
                state.clone(),
                SendWeakRef::from(start_btn.downgrade()),
                SendWeakRef::from(stop_btn.downgrade()),
                mode,
                start_delay,
                interval_ms,
                duration_secs,
                mouse_btn,
                kb_info,
            );
        }
    ));

    stop_btn.connect_clicked(glib::clone!(
        #[strong]
        state,
        #[weak]
        start_btn,
        #[weak]
        stop_btn,
        move |_| {
            if !state.running.load(Ordering::SeqCst) {
                return;
            }
            state.running.store(false, Ordering::SeqCst);
            stop_btn.set_sensitive(false);
            start_btn.set_sensitive(state.ready.load(Ordering::SeqCst));
        }
    ));

    let key_controller = gtk::EventControllerKey::new();
    key_controller.set_propagation_phase(gtk::PropagationPhase::Capture);
    key_controller.connect_key_pressed(glib::clone!(
        #[weak]
        start_btn,
        #[weak]
        stop_btn,
        #[upgrade_or]
        glib::Propagation::Proceed,
        move |_, key, _, _| {
            if key == gdk::Key::F5 {
                if start_btn.is_sensitive() {
                    start_btn.emit_clicked();
                }
                return glib::Propagation::Stop;
            }
            if key == gdk::Key::F6 {
                if stop_btn.is_sensitive() {
                    stop_btn.emit_clicked();
                }
                return glib::Propagation::Stop;
            }
            glib::Propagation::Proceed
        }
    ));
    page.add_controller(key_controller);

    page.connect_unmap(glib::clone!(
        #[strong]
        state,
        #[weak]
        start_btn,
        #[weak]
        stop_btn,
        move |_| {
            if state.running.swap(false, Ordering::SeqCst) {
                stop_btn.set_sensitive(false);
                start_btn.set_sensitive(state.ready.load(Ordering::SeqCst));
            }
        }
    ));

    init_virtual_device(state.clone(), SendWeakRef::from(start_btn.downgrade()));

    page.upcast()
}

fn init_virtual_device(state: Arc<DeviceState>, start_btn: SendWeakRef<gtk::Button>) {
    thread::spawn(move || match create_virtual_device() {
        Ok(device) => {
            *state.device.lock().expect("device lock") = Some(device);
            state.ready.store(true, Ordering::SeqCst);
            glib::MainContext::default().invoke(move || {
                if let Some(btn) = start_btn.upgrade() {
                    btn.set_sensitive(true);
                }
            });
        }
        Err(err) => {
            eprintln!("\n[ERROR] Failed to create virtual device.");
            eprintln!("Ensure you have write permissions to /dev/uinput: {err}");
            eprintln!(
                "Adding user to 'input' group handles /dev/input, but /dev/uinput might need a udev rule.\n"
            );
        }
    });
}

fn create_virtual_device() -> std::io::Result<VirtualDevice> {
    let mut keys = AttributeSet::<KeyCode>::new();
    for code in 1..120 {
        keys.insert(KeyCode::new(code));
    }
    keys.insert(KeyCode::BTN_LEFT);
    keys.insert(KeyCode::BTN_RIGHT);
    keys.insert(KeyCode::BTN_MIDDLE);

    VirtualDevice::builder()?
        .name("macros-menu-virtual")
        .with_keys(&keys)?
        .build()
}

fn start_automation(
    state: Arc<DeviceState>,
    start_btn: SendWeakRef<gtk::Button>,
    stop_btn: SendWeakRef<gtk::Button>,
    mode: String,
    start_delay: u64,
    interval_ms: f64,
    duration_secs: f64,
    mouse_btn: u32,
    kb_info: KbInfo,
) {
    state.running.store(true, Ordering::SeqCst);

    thread::spawn(move || {
        thread::sleep(Duration::from_secs(start_delay));

        let end = if duration_secs > 0.0 {
            Some(Instant::now() + Duration::from_secs_f64(duration_secs))
        } else {
            None
        };

        let interval = if interval_ms > 0.0 {
            Duration::from_secs_f64(interval_ms / 1000.0)
        } else {
            Duration::from_millis(1)
        };

        let mouse_code = match mouse_btn {
            1 => KeyCode::BTN_MIDDLE,
            2 => KeyCode::BTN_RIGHT,
            _ => KeyCode::BTN_LEFT,
        };

        let mut mods = Vec::new();
        if kb_info.shift {
            mods.push(KeyCode::KEY_LEFTSHIFT);
        }
        if kb_info.ctrl {
            mods.push(KeyCode::KEY_LEFTCTRL);
        }
        if kb_info.alt {
            mods.push(KeyCode::KEY_LEFTALT);
        }
        if kb_info.super_key {
            mods.push(KeyCode::KEY_LEFTMETA);
        }

        let key_map = key_map();
        let shift_map = shift_map();

        while state.running.load(Ordering::SeqCst) {
            if let Some(end) = end {
                if Instant::now() >= end {
                    break;
                }
            }

            {
                let mut guard = match state.device.lock() {
                    Ok(guard) => guard,
                    Err(_) => break,
                };
                let Some(device) = guard.as_mut() else {
                    break;
                };

                if mode == "mouse" {
                    let _ = emit_key(device, mouse_code, 1);
                    let _ = emit_key(device, mouse_code, 0);
                } else if mode == "kb" {
                    for &mod_key in &mods {
                        let _ = emit_key(device, mod_key, 1);
                    }

                    if kb_info.action_type == 0 {
                        for ch in kb_info.text.chars() {
                            let (code, need_shift) = if let Some(&code) = key_map.get(&ch) {
                                (Some(code), false)
                            } else if let Some(&code) = shift_map.get(&ch) {
                                (Some(code), true)
                            } else {
                                (None, false)
                            };

                            let Some(code) = code else {
                                continue;
                            };

                            if need_shift {
                                let _ = emit_key(device, KeyCode::KEY_LEFTSHIFT, 1);
                            }
                            let _ = emit_key(device, code, 1);
                            let _ = emit_key(device, code, 0);
                            if need_shift {
                                let _ = emit_key(device, KeyCode::KEY_LEFTSHIFT, 0);
                            }
                        }
                    } else {
                        let _ = emit_key(device, kb_info.key, 1);
                        let _ = emit_key(device, kb_info.key, 0);
                    }

                    for &mod_key in mods.iter().rev() {
                        let _ = emit_key(device, mod_key, 0);
                    }
                }
            }

            thread::sleep(interval);
        }

        state.running.store(false, Ordering::SeqCst);
        let ready = state.ready.load(Ordering::SeqCst);
        glib::MainContext::default().invoke(move || {
            if let Some(btn) = start_btn.upgrade() {
                btn.set_sensitive(ready);
            }
            if let Some(btn) = stop_btn.upgrade() {
                btn.set_sensitive(false);
            }
        });
    });
}

fn emit_key(device: &mut VirtualDevice, code: KeyCode, value: i32) -> std::io::Result<()> {
    device.emit(&[InputEvent::new(EventType::KEY.0, code.code(), value)])
}

fn key_map() -> HashMap<char, KeyCode> {
    HashMap::from([
        ('a', KeyCode::KEY_A),
        ('b', KeyCode::KEY_B),
        ('c', KeyCode::KEY_C),
        ('d', KeyCode::KEY_D),
        ('e', KeyCode::KEY_E),
        ('f', KeyCode::KEY_F),
        ('g', KeyCode::KEY_G),
        ('h', KeyCode::KEY_H),
        ('i', KeyCode::KEY_I),
        ('j', KeyCode::KEY_J),
        ('k', KeyCode::KEY_K),
        ('l', KeyCode::KEY_L),
        ('m', KeyCode::KEY_M),
        ('n', KeyCode::KEY_N),
        ('o', KeyCode::KEY_O),
        ('p', KeyCode::KEY_P),
        ('q', KeyCode::KEY_Q),
        ('r', KeyCode::KEY_R),
        ('s', KeyCode::KEY_S),
        ('t', KeyCode::KEY_T),
        ('u', KeyCode::KEY_U),
        ('v', KeyCode::KEY_V),
        ('w', KeyCode::KEY_W),
        ('x', KeyCode::KEY_X),
        ('y', KeyCode::KEY_Y),
        ('z', KeyCode::KEY_Z),
        ('1', KeyCode::KEY_1),
        ('2', KeyCode::KEY_2),
        ('3', KeyCode::KEY_3),
        ('4', KeyCode::KEY_4),
        ('5', KeyCode::KEY_5),
        ('6', KeyCode::KEY_6),
        ('7', KeyCode::KEY_7),
        ('8', KeyCode::KEY_8),
        ('9', KeyCode::KEY_9),
        ('0', KeyCode::KEY_0),
        (' ', KeyCode::KEY_SPACE),
        ('-', KeyCode::KEY_MINUS),
        ('=', KeyCode::KEY_EQUAL),
        ('[', KeyCode::KEY_LEFTBRACE),
        (']', KeyCode::KEY_RIGHTBRACE),
        ('\\', KeyCode::KEY_BACKSLASH),
        (';', KeyCode::KEY_SEMICOLON),
        ('\'', KeyCode::KEY_APOSTROPHE),
        ('`', KeyCode::KEY_GRAVE),
        (',', KeyCode::KEY_COMMA),
        ('.', KeyCode::KEY_DOT),
        ('/', KeyCode::KEY_SLASH),
    ])
}

fn shift_map() -> HashMap<char, KeyCode> {
    HashMap::from([
        ('A', KeyCode::KEY_A),
        ('B', KeyCode::KEY_B),
        ('C', KeyCode::KEY_C),
        ('D', KeyCode::KEY_D),
        ('E', KeyCode::KEY_E),
        ('F', KeyCode::KEY_F),
        ('G', KeyCode::KEY_G),
        ('H', KeyCode::KEY_H),
        ('I', KeyCode::KEY_I),
        ('J', KeyCode::KEY_J),
        ('K', KeyCode::KEY_K),
        ('L', KeyCode::KEY_L),
        ('M', KeyCode::KEY_M),
        ('N', KeyCode::KEY_N),
        ('O', KeyCode::KEY_O),
        ('P', KeyCode::KEY_P),
        ('Q', KeyCode::KEY_Q),
        ('R', KeyCode::KEY_R),
        ('S', KeyCode::KEY_S),
        ('T', KeyCode::KEY_T),
        ('U', KeyCode::KEY_U),
        ('V', KeyCode::KEY_V),
        ('W', KeyCode::KEY_W),
        ('X', KeyCode::KEY_X),
        ('Y', KeyCode::KEY_Y),
        ('Z', KeyCode::KEY_Z),
        ('!', KeyCode::KEY_1),
        ('@', KeyCode::KEY_2),
        ('#', KeyCode::KEY_3),
        ('$', KeyCode::KEY_4),
        ('%', KeyCode::KEY_5),
        ('^', KeyCode::KEY_6),
        ('&', KeyCode::KEY_7),
        ('*', KeyCode::KEY_8),
        ('(', KeyCode::KEY_9),
        (')', KeyCode::KEY_0),
        ('_', KeyCode::KEY_MINUS),
        ('+', KeyCode::KEY_EQUAL),
        ('{', KeyCode::KEY_LEFTBRACE),
        ('}', KeyCode::KEY_RIGHTBRACE),
        ('|', KeyCode::KEY_BACKSLASH),
        (':', KeyCode::KEY_SEMICOLON),
        ('"', KeyCode::KEY_APOSTROPHE),
        ('~', KeyCode::KEY_GRAVE),
        ('<', KeyCode::KEY_COMMA),
        ('>', KeyCode::KEY_DOT),
        ('?', KeyCode::KEY_SLASH),
    ])
}
