use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
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

#[derive(Clone, Debug)]
struct WifiNetwork {
    ssid: String,
    bssid: String,
    signal: i32,
    security: String,
    in_use: bool,
    freq: String,
}

#[derive(Clone, Debug)]
struct SavedNetwork {
    name: String,
    uuid: String,
    active: bool,
    autoconnect: bool,
}

#[derive(Clone, Debug)]
struct EthernetInfo {
    device: String,
    state: String,
    connection: String,
    ip4: String,
}

struct WifiSnapshot {
    wifi_enabled: bool,
    wifi_device: String,
    active_ssid: String,
    ethernet: Vec<EthernetInfo>,
    scanned: Vec<WifiNetwork>,
    saved: Vec<SavedNetwork>,
}

struct UiState {
    ethernet_fp: String,
    connected_fp: String,
    known_fp: String,
    available_fp: String,
    scanning: bool,
    updating: bool,
    refreshing: bool,
}

type RefreshHandle = Rc<RefCell<Option<Rc<dyn Fn()>>>>;

struct HeaderWidgets<'a> {
    power_switch: &'a gtk::Switch,
    scan_btn: &'a gtk::Button,
    scan_spinner: &'a gtk::Spinner,
}

struct SectionWidgets<'a> {
    ethernet_box: &'a gtk::Box,
    connected_box: &'a gtk::Box,
    known_box: &'a gtk::Box,
    available_box: &'a gtk::Box,
    ethernet_label: &'a gtk::Label,
    connected_label: &'a gtk::Label,
    known_label: &'a gtk::Label,
    available_label: &'a gtk::Label,
}

pub fn component() -> Component {
    Component {
        id: "network",
        title: "Network",
        icon: "network-wireless-symbolic",
        build,
    }
}

fn build() -> gtk::Widget {
    let root = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(6)
        .build();

    let power_switch = gtk::Switch::builder()
        .valign(gtk::Align::Center)
        .tooltip_text("Wi-Fi")
        .build();

    let power_label = gtk::Label::builder()
        .label("Wi-Fi")
        .css_classes(["heading"])
        .valign(gtk::Align::Center)
        .build();

    let scan_btn = gtk::Button::builder()
        .icon_name("edit-find-symbolic")
        .tooltip_text("Scan for networks")
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
        .placeholder_text("Filter networks…")
        .margin_start(12)
        .margin_end(12)
        .build();

    let ethernet_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(4)
        .build();
    let connected_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(4)
        .build();
    let known_box = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(4)
        .build();
    let available_box = gtk::Box::builder()
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

    let ethernet_label = section_label("Ethernet");
    let connected_label = section_label("Connected");
    let known_label = section_label("Known networks");
    let available_label = section_label("Available");

    content.append(&ethernet_label);
    content.append(&ethernet_box);
    content.append(&connected_label);
    content.append(&connected_box);
    content.append(&known_label);
    content.append(&known_box);
    content.append(&available_label);
    content.append(&available_box);

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
    let ethernet_box_w = ethernet_box.downgrade();
    let connected_box_w = connected_box.downgrade();
    let known_box_w = known_box.downgrade();
    let available_box_w = available_box.downgrade();
    let ethernet_label_w = ethernet_label.downgrade();
    let connected_label_w = connected_label.downgrade();
    let known_label_w = known_label.downgrade();
    let available_label_w = available_label.downgrade();

    let state = Rc::new(RefCell::new(UiState {
        ethernet_fp: String::new(),
        connected_fp: String::new(),
        known_fp: String::new(),
        available_fp: String::new(),
        scanning: false,
        updating: false,
        refreshing: false,
    }));

    let query = Rc::new(RefCell::new(String::new()));

    let refresh: RefreshHandle = Rc::new(RefCell::new(None));

    let do_refresh = Rc::new(glib::clone!(
        #[strong]
        power_switch_w,
        #[strong]
        scan_btn_w,
        #[strong]
        scan_spinner_w,
        #[strong]
        ethernet_box_w,
        #[strong]
        connected_box_w,
        #[strong]
        known_box_w,
        #[strong]
        available_box_w,
        #[strong]
        ethernet_label_w,
        #[strong]
        connected_label_w,
        #[strong]
        known_label_w,
        #[strong]
        available_label_w,
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
                fetch_snapshot,
                glib::clone!(
                    #[strong]
                    power_switch_w,
                    #[strong]
                    scan_btn_w,
                    #[strong]
                    scan_spinner_w,
                    #[strong]
                    ethernet_box_w,
                    #[strong]
                    connected_box_w,
                    #[strong]
                    known_box_w,
                    #[strong]
                    available_box_w,
                    #[strong]
                    ethernet_label_w,
                    #[strong]
                    connected_label_w,
                    #[strong]
                    known_label_w,
                    #[strong]
                    available_label_w,
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
                        let Some(ethernet_box) = ethernet_box_w.upgrade() else {
                            return;
                        };
                        let Some(connected_box) = connected_box_w.upgrade() else {
                            return;
                        };
                        let Some(known_box) = known_box_w.upgrade() else {
                            return;
                        };
                        let Some(available_box) = available_box_w.upgrade() else {
                            return;
                        };
                        let Some(ethernet_label) = ethernet_label_w.upgrade() else {
                            return;
                        };
                        let Some(connected_label) = connected_label_w.upgrade() else {
                            return;
                        };
                        let Some(known_label) = known_label_w.upgrade() else {
                            return;
                        };
                        let Some(available_label) = available_label_w.upgrade() else {
                            return;
                        };
                        apply_snapshot(
                            HeaderWidgets {
                                power_switch: &power_switch,
                                scan_btn: &scan_btn,
                                scan_spinner: &scan_spinner,
                            },
                            SectionWidgets {
                                ethernet_box: &ethernet_box,
                                connected_box: &connected_box,
                                known_box: &known_box,
                                available_box: &available_box,
                                ethernet_label: &ethernet_label,
                                connected_label: &connected_label,
                                known_label: &known_label,
                                available_label: &available_label,
                            },
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
            set_wifi_enabled(active);
            if !active {
                state.borrow_mut().scanning = false;
            }
            glib::timeout_add_local_once(
                Duration::from_millis(200),
                glib::clone!(
                    #[strong]
                    do_refresh,
                    #[weak]
                    switch,
                    move || {
                        let _ = &switch;
                        do_refresh();
                    }
                ),
            );
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
                state.borrow_mut().scanning = false;
            } else {
                state.borrow_mut().scanning = true;
                let _ = nm(&["device", "wifi", "rescan"]);
                glib::timeout_add_local_once(
                    Duration::from_secs(30),
                    glib::clone!(
                        #[strong]
                        state,
                        #[strong]
                        do_refresh,
                        move || {
                            if state.borrow().scanning {
                                state.borrow_mut().scanning = false;
                                do_refresh();
                            }
                        }
                    ),
                );
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

    do_refresh();

    glib::timeout_add_local(
        Duration::from_millis(2000),
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

fn fetch_snapshot() -> WifiSnapshot {
    let wifi_device = wifi_device_name();
    let active_ssid = active_wifi_ssid(&wifi_device);
    WifiSnapshot {
        wifi_enabled: wifi_enabled(),
        wifi_device,
        active_ssid,
        ethernet: list_ethernet(),
        scanned: list_wifi_networks(),
        saved: list_saved_networks(),
    }
}

fn apply_snapshot(
    header: HeaderWidgets<'_>,
    sections: SectionWidgets<'_>,
    state: &Rc<RefCell<UiState>>,
    query: &str,
    refresh: Rc<dyn Fn()>,
    snapshot: WifiSnapshot,
) {
    let scanning = state.borrow().scanning;

    state.borrow_mut().updating = true;
    if header.power_switch.is_active() != snapshot.wifi_enabled {
        header.power_switch.set_active(snapshot.wifi_enabled);
    }
    header.scan_btn.set_sensitive(snapshot.wifi_enabled);
    header.scan_spinner.set_visible(scanning);
    if scanning {
        header.scan_spinner.start();
        header
            .scan_btn
            .set_icon_name("media-playback-stop-symbolic");
        header.scan_btn.set_tooltip_text(Some("Stop scanning"));
    } else {
        header.scan_spinner.stop();
        header.scan_btn.set_icon_name("edit-find-symbolic");
        header.scan_btn.set_tooltip_text(Some("Scan for networks"));
    }
    state.borrow_mut().updating = false;

    let saved_names: HashSet<String> = snapshot
        .saved
        .iter()
        .map(|s| s.name.to_lowercase())
        .collect();

    let connected_scan = snapshot
        .scanned
        .iter()
        .find(|n| n.in_use || n.ssid == snapshot.active_ssid)
        .cloned();

    let known: Vec<SavedNetwork> = snapshot
        .saved
        .iter()
        .filter(|s| !s.active)
        .filter(|s| matches_query(&s.name, "", query))
        .cloned()
        .collect();

    let available: Vec<WifiNetwork> = snapshot
        .scanned
        .iter()
        .filter(|n| !n.in_use && n.ssid != snapshot.active_ssid)
        .filter(|n| !saved_names.contains(&n.ssid.to_lowercase()))
        .filter(|n| matches_query(&display_ssid(&n.ssid), &n.bssid, query))
        .cloned()
        .collect();

    let ethernet_fp = ethernet_fingerprint(&snapshot.ethernet);
    let connected_fp = connected_fingerprint(
        &snapshot.active_ssid,
        connected_scan.as_ref(),
        &snapshot.wifi_device,
        snapshot.saved.iter().find(|s| s.active),
    );
    let known_fp = known_fingerprint(query, &known);
    let available_fp = available_fingerprint(query, &available);

    if state.borrow().ethernet_fp != ethernet_fp {
        state.borrow_mut().ethernet_fp = ethernet_fp;
        rebuild_ethernet_section(
            sections.ethernet_box,
            sections.ethernet_label,
            &snapshot.ethernet,
            &refresh,
        );
    }

    if state.borrow().connected_fp != connected_fp {
        state.borrow_mut().connected_fp = connected_fp;
        rebuild_connected_section(
            sections.connected_box,
            sections.connected_label,
            &snapshot.active_ssid,
            connected_scan.as_ref(),
            &snapshot.wifi_device,
            snapshot.saved.iter().find(|s| s.active).cloned(),
            &refresh,
        );
    } else {
        let signal = connected_scan.map(|n| n.signal).unwrap_or(0);
        update_connected_signal(sections.connected_box, signal);
    }

    if state.borrow().known_fp != known_fp {
        state.borrow_mut().known_fp = known_fp;
        rebuild_known_section(sections.known_box, sections.known_label, &known, &refresh);
    }

    if state.borrow().available_fp != available_fp {
        state.borrow_mut().available_fp = available_fp;
        rebuild_available_section(
            sections.available_box,
            sections.available_label,
            &available,
            &refresh,
        );
    } else {
        update_available_signals(sections.available_box, &available);
    }
}

fn ethernet_fingerprint(devices: &[EthernetInfo]) -> String {
    devices
        .iter()
        .map(|e| format!("{}|{}|{}|{}", e.device, e.state, e.connection, e.ip4))
        .collect::<Vec<_>>()
        .join(";")
}

fn connected_fingerprint(
    active_ssid: &str,
    scan_info: Option<&WifiNetwork>,
    wifi_device: &str,
    saved: Option<&SavedNetwork>,
) -> String {
    let security = scan_info.map(|n| n.security.as_str()).unwrap_or("");
    let freq = scan_info.map(|n| n.freq.as_str()).unwrap_or("");
    let autoconnect = saved.map(|s| s.autoconnect as u8).unwrap_or(0);
    let uuid = saved.map(|s| s.uuid.as_str()).unwrap_or("");
    format!("{active_ssid}|{wifi_device}|{security}|{freq}|{uuid}|{autoconnect}")
}

fn known_fingerprint(query: &str, networks: &[SavedNetwork]) -> String {
    let mut parts = vec![format!("q={query}")];
    for s in networks {
        parts.push(format!("{}|{}|{}", s.uuid, s.autoconnect as u8, s.name));
    }
    parts.join(";")
}

fn available_fingerprint(query: &str, networks: &[WifiNetwork]) -> String {
    let mut parts = vec![format!("q={query}")];
    for n in networks {
        parts.push(format!(
            "{}|{}|{}|{}",
            network_key(n),
            n.security,
            n.freq,
            n.bssid
        ));
    }
    parts.join(";")
}

fn network_key(network: &WifiNetwork) -> String {
    if network.ssid.is_empty() {
        format!("__hidden__{}", network.bssid)
    } else {
        network.ssid.clone()
    }
}

fn matches_query(ssid: &str, bssid: &str, query: &str) -> bool {
    if query.is_empty() {
        return true;
    }
    ssid.to_lowercase().contains(query) || bssid.to_lowercase().contains(query)
}

fn rebuild_ethernet_section(
    container: &gtk::Box,
    label: &gtk::Label,
    devices: &[EthernetInfo],
    refresh: &Rc<dyn Fn()>,
) {
    clear_box(container);
    if devices.is_empty() {
        label.set_visible(false);
        return;
    }
    label.set_visible(true);
    for device in devices {
        container.append(&build_ethernet_row(device, refresh.clone()));
    }
}

fn rebuild_connected_section(
    container: &gtk::Box,
    label: &gtk::Label,
    active_ssid: &str,
    scan_info: Option<&WifiNetwork>,
    wifi_device: &str,
    saved: Option<SavedNetwork>,
    refresh: &Rc<dyn Fn()>,
) {
    clear_box(container);
    if active_ssid.is_empty() {
        label.set_visible(true);
        container.append(&empty_label("Not connected to Wi-Fi"));
        return;
    }
    label.set_visible(true);
    let signal = scan_info.map(|n| n.signal).unwrap_or(0);
    let security = scan_info.map(|n| n.security.clone()).unwrap_or_default();
    let freq = scan_info.map(|n| n.freq.clone()).unwrap_or_default();
    container.append(&build_connected_row(
        active_ssid,
        signal,
        &security,
        &freq,
        wifi_device,
        saved.as_ref(),
        refresh.clone(),
    ));
}

fn rebuild_known_section(
    container: &gtk::Box,
    label: &gtk::Label,
    networks: &[SavedNetwork],
    refresh: &Rc<dyn Fn()>,
) {
    clear_box(container);
    label.set_visible(true);
    if networks.is_empty() {
        container.append(&empty_label("No saved networks"));
        return;
    }
    for network in networks {
        container.append(&build_known_row(network, refresh.clone()));
    }
}

fn rebuild_available_section(
    container: &gtk::Box,
    label: &gtk::Label,
    networks: &[WifiNetwork],
    refresh: &Rc<dyn Fn()>,
) {
    clear_box(container);
    label.set_visible(true);
    if networks.is_empty() {
        container.append(&empty_label("No networks found"));
        return;
    }
    for network in networks {
        container.append(&build_available_row(network, refresh.clone()));
    }
}

fn build_ethernet_row(device: &EthernetInfo, refresh: Rc<dyn Fn()>) -> gtk::Box {
    let row = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(10)
        .margin_top(4)
        .margin_bottom(4)
        .build();

    let icon = gtk::Image::from_icon_name("network-wired-symbolic");
    icon.set_pixel_size(28);
    icon.set_valign(gtk::Align::Center);

    let text_col = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(2)
        .hexpand(true)
        .valign(gtk::Align::Center)
        .build();

    let title = if device.connection.is_empty() {
        device.device.clone()
    } else {
        device.connection.clone()
    };

    let name = gtk::Label::builder()
        .label(&title)
        .xalign(0.0)
        .ellipsize(pango::EllipsizeMode::End)
        .build();

    let mut meta_parts = vec![device.device.clone(), device.state.clone()];
    if !device.ip4.is_empty() {
        meta_parts.push(device.ip4.clone());
    }
    let meta = gtk::Label::builder()
        .label(meta_parts.join(" · "))
        .xalign(0.0)
        .ellipsize(pango::EllipsizeMode::End)
        .css_classes(["dim-label", "caption"])
        .build();

    text_col.append(&name);
    text_col.append(&meta);

    row.append(&icon);
    row.append(&text_col);

    if device.state.contains("connected") {
        let dev = device.device.clone();
        let disconnect = gtk::Button::builder()
            .label("Disconnect")
            .valign(gtk::Align::Center)
            .css_classes(["destructive-action"])
            .build();
        disconnect.connect_clicked(move |_| {
            let _ = nm(&["device", "disconnect", &dev]);
            refresh();
        });
        row.append(&disconnect);
    }

    row
}

fn build_connected_row(
    ssid: &str,
    signal: i32,
    security: &str,
    freq: &str,
    wifi_device: &str,
    saved: Option<&SavedNetwork>,
    refresh: Rc<dyn Fn()>,
) -> gtk::Box {
    let row = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(10)
        .margin_top(4)
        .margin_bottom(4)
        .build();

    let icon = gtk::Image::from_icon_name(signal_icon(signal));
    icon.set_pixel_size(28);
    icon.set_valign(gtk::Align::Center);

    let text_col = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(2)
        .hexpand(true)
        .valign(gtk::Align::Center)
        .build();

    let name = gtk::Label::builder()
        .label(ssid)
        .xalign(0.0)
        .ellipsize(pango::EllipsizeMode::End)
        .build();

    let mut meta_parts = vec!["Connected".to_string()];
    if !security.is_empty() {
        meta_parts.push(security.to_string());
    }
    if !freq.is_empty() {
        meta_parts.push(freq.to_string());
    }

    let meta = gtk::Label::builder()
        .label(meta_parts.join(" · "))
        .xalign(0.0)
        .ellipsize(pango::EllipsizeMode::End)
        .css_classes(["dim-label", "caption"])
        .build();

    text_col.append(&name);
    text_col.append(&meta);

    row.append(&icon);
    row.append(&text_col);
    row.append(&signal_indicator(signal));

    let dev = wifi_device.to_string();
    let disconnect = gtk::Button::builder()
        .label("Disconnect")
        .valign(gtk::Align::Center)
        .css_classes(["destructive-action"])
        .build();
    disconnect.connect_clicked({
        let refresh = refresh.clone();
        move |_| {
            if !dev.is_empty() {
                let _ = nm(&["device", "disconnect", &dev]);
            }
            refresh();
        }
    });
    row.append(&disconnect);

    if let Some(saved) = saved {
        let menu_btn = gtk::MenuButton::builder()
            .icon_name("view-more-symbolic")
            .has_frame(false)
            .valign(gtk::Align::Center)
            .tooltip_text("Network actions")
            .direction(gtk::ArrowType::Down)
            .build();
        menu_btn.set_popover(Some(&build_known_popover(saved, &row, refresh)));
        row.append(&menu_btn);
    }

    row
}

fn build_known_row(network: &SavedNetwork, refresh: Rc<dyn Fn()>) -> gtk::Box {
    let row = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(10)
        .margin_top(4)
        .margin_bottom(4)
        .build();

    let icon = gtk::Image::from_icon_name("network-wireless-symbolic");
    icon.set_pixel_size(28);
    icon.set_valign(gtk::Align::Center);

    let text_col = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(2)
        .hexpand(true)
        .valign(gtk::Align::Center)
        .build();

    let name = gtk::Label::builder()
        .label(&network.name)
        .xalign(0.0)
        .ellipsize(pango::EllipsizeMode::End)
        .build();

    let meta = gtk::Label::builder()
        .label(if network.autoconnect {
            "Auto-connect enabled"
        } else {
            "Auto-connect disabled"
        })
        .xalign(0.0)
        .ellipsize(pango::EllipsizeMode::End)
        .css_classes(["dim-label", "caption"])
        .build();

    text_col.append(&name);
    text_col.append(&meta);

    row.append(&icon);
    row.append(&text_col);

    let uuid = network.uuid.clone();
    let connect = gtk::Button::builder()
        .label("Connect")
        .valign(gtk::Align::Center)
        .css_classes(["suggested-action"])
        .build();
    connect.connect_clicked({
        let refresh = refresh.clone();
        let uuid = uuid.clone();
        move |_| {
            let _ = nm(&["connection", "up", &uuid]);
            refresh();
        }
    });
    row.append(&connect);

    let menu_btn = gtk::MenuButton::builder()
        .icon_name("view-more-symbolic")
        .has_frame(false)
        .valign(gtk::Align::Center)
        .tooltip_text("Network actions")
        .direction(gtk::ArrowType::Down)
        .build();
    menu_btn.set_popover(Some(&build_known_popover(network, &row, refresh)));

    row.append(&menu_btn);
    row
}

fn build_available_row(network: &WifiNetwork, refresh: Rc<dyn Fn()>) -> gtk::Box {
    let row = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(10)
        .margin_top(4)
        .margin_bottom(4)
        .build();
    row.set_widget_name(&network_key(network));

    let icon = gtk::Image::from_icon_name(signal_icon(network.signal));
    icon.set_pixel_size(28);
    icon.set_valign(gtk::Align::Center);

    let text_col = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(2)
        .hexpand(true)
        .valign(gtk::Align::Center)
        .build();

    let display = display_ssid(&network.ssid);
    let name = gtk::Label::builder()
        .label(&display)
        .xalign(0.0)
        .ellipsize(pango::EllipsizeMode::End)
        .build();

    let mut meta_parts = Vec::new();
    if !network.security.is_empty() {
        meta_parts.push(network.security.clone());
    }
    if !network.freq.is_empty() {
        meta_parts.push(network.freq.clone());
    }
    meta_parts.push(format!("{}%", network.signal));

    let meta = gtk::Label::builder()
        .label(meta_parts.join(" · "))
        .xalign(0.0)
        .ellipsize(pango::EllipsizeMode::End)
        .css_classes(["dim-label", "caption"])
        .build();

    text_col.append(&name);
    text_col.append(&meta);

    row.append(&icon);
    row.append(&text_col);

    let ssid = network.ssid.clone();
    let security = network.security.clone();
    let connect = gtk::Button::builder()
        .label("Connect")
        .valign(gtk::Align::Center)
        .css_classes(["suggested-action"])
        .build();
    connect.connect_clicked({
        let refresh = refresh.clone();
        let parent = row.clone();
        move |_| {
            prompt_connect(&parent, &ssid, &security, None, refresh.clone());
        }
    });
    row.append(&connect);

    row
}

fn build_known_popover(
    network: &SavedNetwork,
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

    let uuid = network.uuid.clone();
    let name = network.name.clone();

    if network.autoconnect {
        box_.append(&popover_btn("Disable auto-connect", false, {
            let uuid = uuid.clone();
            let refresh = refresh.clone();
            move || {
                set_autoconnect(&uuid, false);
                refresh();
            }
        }));
    } else {
        box_.append(&popover_btn("Enable auto-connect", false, {
            let uuid = uuid.clone();
            let refresh = refresh.clone();
            move || {
                set_autoconnect(&uuid, true);
                refresh();
            }
        }));
    }

    box_.append(&gtk::Separator::new(gtk::Orientation::Horizontal));

    box_.append(&popover_btn("Remove", true, {
        let uuid = uuid.clone();
        let name = name.clone();
        let parent = parent.clone();
        let refresh = refresh.clone();
        move || {
            confirm_remove(&parent, &uuid, &name, refresh.clone());
        }
    }));

    gtk::Popover::builder().child(&box_).build()
}

fn popover_btn(label: &str, destructive: bool, on_click: impl Fn() + 'static) -> gtk::Button {
    let btn = gtk::Button::builder()
        .label(label)
        .has_frame(false)
        .halign(gtk::Align::Fill)
        .build();
    if let Some(child) = btn.child()
        && let Some(lbl) = child.downcast_ref::<gtk::Label>()
    {
        lbl.set_xalign(0.0);
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

fn prompt_connect(
    parent: &impl IsA<gtk::Widget>,
    ssid: &str,
    security: &str,
    saved_uuid: Option<&str>,
    refresh: Rc<dyn Fn()>,
) {
    if let Some(uuid) = saved_uuid {
        let _ = nm(&["connection", "up", uuid]);
        refresh();
        return;
    }

    let needs_password = !security.is_empty() && !security.eq_ignore_ascii_case("--");
    if !needs_password {
        connect_wifi(ssid, None);
        refresh();
        return;
    }

    let display = display_ssid(ssid);
    let dialog = adw::AlertDialog::new(
        Some("Connect to Network"),
        Some(&format!("Enter the password for \"{display}\":")),
    );

    let entry = gtk::PasswordEntry::builder().show_peek_icon(true).build();
    dialog.set_extra_child(Some(&entry));

    dialog.add_response("cancel", "Cancel");
    dialog.add_response("connect", "Connect");
    dialog.set_response_appearance("connect", adw::ResponseAppearance::Suggested);
    dialog.set_close_response("cancel");
    dialog.set_default_response(Some("connect"));

    let ssid = ssid.to_string();
    dialog.choose(Some(parent), None::<&gio::Cancellable>, move |response| {
        if response != "connect" {
            return;
        }
        let password = entry.text().to_string();
        connect_wifi(&ssid, Some(&password));
        refresh();
    });
}

fn confirm_remove(parent: &impl IsA<gtk::Widget>, uuid: &str, name: &str, refresh: Rc<dyn Fn()>) {
    let dialog = adw::AlertDialog::new(
        Some("Remove Network?"),
        Some(&format!(
            "Remove \"{name}\" from known networks? You will need to enter the password again to reconnect."
        )),
    );

    dialog.add_response("cancel", "Cancel");
    dialog.add_response("remove", "Remove");
    dialog.set_response_appearance("remove", adw::ResponseAppearance::Destructive);
    dialog.set_close_response("cancel");
    dialog.set_default_response(Some("cancel"));

    let uuid = uuid.to_string();
    dialog.choose(Some(parent), None::<&gio::Cancellable>, move |response| {
        if response != "remove" {
            return;
        }
        let _ = nm(&["connection", "delete", &uuid]);
        refresh();
    });
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

fn display_ssid(ssid: &str) -> String {
    if ssid.is_empty() {
        "(Hidden network)".to_string()
    } else {
        ssid.to_string()
    }
}

fn signal_icon(signal: i32) -> &'static str {
    if signal >= 80 {
        "network-wireless-signal-excellent-symbolic"
    } else if signal >= 60 {
        "network-wireless-signal-good-symbolic"
    } else if signal >= 40 {
        "network-wireless-signal-ok-symbolic"
    } else if signal >= 20 {
        "network-wireless-signal-weak-symbolic"
    } else {
        "network-wireless-signal-none-symbolic"
    }
}

fn signal_level(signal: i32) -> &'static str {
    let signal = signal.clamp(0, 100);
    if signal <= 15 {
        "critical"
    } else if signal <= 30 {
        "low"
    } else if signal <= 60 {
        "medium"
    } else {
        "ok"
    }
}

fn signal_indicator(signal: i32) -> gtk::Widget {
    ensure_signal_css();

    let signal = signal.clamp(0, 100);
    let level = signal_level(signal);

    let bar = gtk::ProgressBar::builder()
        .fraction(f64::from(signal) / 100.0)
        .show_text(false)
        .valign(gtk::Align::Center)
        .tooltip_text(format!("Signal {signal}%"))
        .css_classes(["wifi-signal-bar", level])
        .build();
    bar.set_size_request(48, 6);
    bar.upcast()
}

fn ensure_signal_css() {
    use std::sync::Once;
    static LOAD: Once = Once::new();
    LOAD.call_once(|| {
        let provider = gtk::CssProvider::new();
        provider.load_from_string(
            "
            progressbar.wifi-signal-bar {
                min-width: 48px;
                min-height: 6px;
            }
            progressbar.wifi-signal-bar trough {
                border: none;
                border-radius: 3px;
                padding: 0;
                background-color: alpha(currentColor, 0.15);
                min-height: 6px;
            }
            progressbar.wifi-signal-bar progress {
                border-radius: 3px;
                min-height: 6px;
                background-color: #3fb950;
            }
            progressbar.wifi-signal-bar.medium progress {
                background-color: #d29922;
            }
            progressbar.wifi-signal-bar.low progress {
                background-color: #db6d28;
            }
            progressbar.wifi-signal-bar.critical progress {
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

fn find_signal_bar(row: &gtk::Box) -> Option<gtk::ProgressBar> {
    let mut child = row.last_child();
    while let Some(widget) = child {
        if let Some(bar) = widget.downcast_ref::<gtk::ProgressBar>()
            && bar.has_css_class("wifi-signal-bar")
        {
            return Some(bar.clone());
        }
        child = widget.prev_sibling();
    }
    None
}

fn apply_signal_bar(bar: &gtk::ProgressBar, signal: i32) {
    let signal = signal.clamp(0, 100);
    let level = signal_level(signal);
    bar.set_fraction(f64::from(signal) / 100.0);
    bar.set_tooltip_text(Some(&format!("Signal {signal}%")));
    for class in ["ok", "medium", "low", "critical"] {
        bar.remove_css_class(class);
    }
    bar.add_css_class(level);
}

fn update_connected_signal(container: &gtk::Box, signal: i32) {
    let Some(row) = container.first_child() else {
        return;
    };
    let Some(row) = row.downcast_ref::<gtk::Box>() else {
        return;
    };
    if let Some(icon) = row.first_child().and_downcast::<gtk::Image>() {
        icon.set_icon_name(Some(signal_icon(signal)));
    }
    if let Some(bar) = find_signal_bar(row) {
        apply_signal_bar(&bar, signal);
    }
}

fn update_available_signals(container: &gtk::Box, networks: &[WifiNetwork]) {
    let signals: HashMap<String, i32> = networks
        .iter()
        .map(|n| (network_key(n), n.signal))
        .collect();

    let mut child = container.first_child();
    while let Some(widget) = child {
        child = widget.next_sibling();
        let Some(row) = widget.downcast_ref::<gtk::Box>() else {
            continue;
        };
        let key = row.widget_name();
        if key.is_empty() {
            continue;
        }
        let Some(&signal) = signals.get(key.as_str()) else {
            continue;
        };
        if let Some(icon) = row.first_child().and_downcast::<gtk::Image>() {
            icon.set_icon_name(Some(signal_icon(signal)));
        }
    }
}

fn nm(args: &[&str]) -> std::process::Output {
    Command::new("nmcli")
        .args(args)
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .output()
        .unwrap_or_else(|_| Command::new("true").output().expect("true"))
}

fn nm_stdout(args: &[&str]) -> String {
    String::from_utf8_lossy(&nm(args).stdout).trim().to_string()
}

fn split_nmcli_fields(line: &str) -> Vec<String> {
    let mut fields = Vec::new();
    let mut current = String::new();
    let mut chars = line.chars().peekable();
    while let Some(c) = chars.next() {
        if c == '\\' {
            match chars.next() {
                Some(':') => current.push(':'),
                Some('\\') => current.push('\\'),
                Some('n') => current.push('\n'),
                Some(other) => {
                    current.push('\\');
                    current.push(other);
                }
                None => current.push('\\'),
            }
        } else if c == ':' {
            fields.push(std::mem::take(&mut current));
        } else {
            current.push(c);
        }
    }
    fields.push(current);
    fields
}

fn wifi_enabled() -> bool {
    nm_stdout(&["radio", "wifi"]) == "enabled"
}

fn set_wifi_enabled(on: bool) {
    let _ = nm(&["radio", "wifi", if on { "on" } else { "off" }]);
}

fn wifi_device_name() -> String {
    let output = nm_stdout(&["-t", "-f", "DEVICE,TYPE,STATE", "device", "status"]);
    for line in output.lines() {
        let fields = split_nmcli_fields(line);
        if fields.len() >= 2 && fields[1] == "wifi" {
            return fields[0].clone();
        }
    }
    String::new()
}

fn active_wifi_ssid(wifi_device: &str) -> String {
    if wifi_device.is_empty() {
        return String::new();
    }
    let output = nm_stdout(&[
        "-t",
        "-f",
        "GENERAL.CONNECTION",
        "device",
        "show",
        wifi_device,
    ]);
    for line in output.lines() {
        let fields = split_nmcli_fields(line);
        if fields.len() >= 2 && fields[0] == "GENERAL.CONNECTION" {
            let name = fields[1].clone();
            if name != "--" {
                return name;
            }
        }
    }
    String::new()
}

fn list_ethernet() -> Vec<EthernetInfo> {
    let output = nm_stdout(&[
        "-t",
        "-f",
        "DEVICE,TYPE,STATE,CONNECTION",
        "device",
        "status",
    ]);
    let mut devices = Vec::new();

    for line in output.lines() {
        let fields = split_nmcli_fields(line);
        if fields.len() < 3 {
            continue;
        }
        let device = &fields[0];
        let kind = &fields[1];
        let state = &fields[2];
        let connection = fields.get(3).cloned().unwrap_or_default();

        if kind != "ethernet" {
            continue;
        }
        if state == "unmanaged" || state == "unavailable" {
            continue;
        }
        if !state.contains("connected") && connection.is_empty() {
            continue;
        }

        let detail = nm_stdout(&[
            "-t",
            "-f",
            "GENERAL.STATE,IP4.ADDRESS",
            "device",
            "show",
            device,
        ]);
        let mut ip4 = String::new();
        for detail_line in detail.lines() {
            let detail_fields = split_nmcli_fields(detail_line);
            if detail_fields.len() >= 2 && detail_fields[0].starts_with("IP4.ADDRESS") {
                ip4 = detail_fields[1].split('/').next().unwrap_or("").to_string();
                break;
            }
        }

        devices.push(EthernetInfo {
            device: device.clone(),
            state: state.clone(),
            connection: if connection == "--" {
                String::new()
            } else {
                connection
            },
            ip4,
        });
    }

    devices
}

fn list_wifi_networks() -> Vec<WifiNetwork> {
    let output = nm_stdout(&[
        "-t",
        "-f",
        "IN-USE,SSID,BSSID,SIGNAL,SECURITY,FREQ",
        "device",
        "wifi",
        "list",
    ]);

    let mut by_ssid: HashMap<String, WifiNetwork> = HashMap::new();

    for line in output.lines() {
        let fields = split_nmcli_fields(line);
        if fields.len() < 5 {
            continue;
        }
        let in_use = fields[0] == "*";
        let ssid = fields[1].clone();
        let bssid = fields[2].clone();
        let signal: i32 = fields[3].parse().unwrap_or(0);
        let security = fields[4].clone();
        let freq = fields.get(5).cloned().unwrap_or_default();

        let key = if ssid.is_empty() {
            format!("__hidden__{bssid}")
        } else {
            ssid.clone()
        };

        let entry = WifiNetwork {
            ssid,
            bssid,
            signal,
            security,
            in_use,
            freq,
        };

        match by_ssid.get(&key) {
            Some(existing) if existing.signal >= entry.signal => {}
            _ => {
                by_ssid.insert(key, entry);
            }
        }
    }

    let mut networks: Vec<WifiNetwork> = by_ssid.into_values().collect();
    networks.sort_by(|a, b| {
        b.in_use.cmp(&a.in_use).then(b.signal.cmp(&a.signal)).then(
            display_ssid(&a.ssid)
                .to_lowercase()
                .cmp(&display_ssid(&b.ssid).to_lowercase()),
        )
    });
    networks
}

fn list_saved_networks() -> Vec<SavedNetwork> {
    let output = nm_stdout(&[
        "-t",
        "-f",
        "NAME,UUID,TYPE,DEVICE,STATE,AUTOCONNECT",
        "connection",
        "show",
    ]);

    let mut networks = Vec::new();
    for line in output.lines() {
        let fields = split_nmcli_fields(line);
        if fields.len() < 6 {
            continue;
        }
        if fields[2] != "802-11-wireless" {
            continue;
        }
        let state = fields[4].clone();
        networks.push(SavedNetwork {
            name: fields[0].clone(),
            uuid: fields[1].clone(),
            active: state == "activated",
            autoconnect: fields[5].eq_ignore_ascii_case("yes"),
        });
    }

    networks.sort_by(|a, b| {
        b.active
            .cmp(&a.active)
            .then(a.name.to_lowercase().cmp(&b.name.to_lowercase()))
    });
    networks
}

fn connect_wifi(ssid: &str, password: Option<&str>) {
    let wifi_dev = wifi_device_name();
    let mut args: Vec<String> = vec![
        "device".into(),
        "wifi".into(),
        "connect".into(),
        ssid.to_string(),
    ];
    if let Some(pw) = password.filter(|p| !p.is_empty()) {
        args.push("password".into());
        args.push(pw.to_string());
    }
    if !wifi_dev.is_empty() {
        args.push("ifname".into());
        args.push(wifi_dev);
    }
    let refs: Vec<&str> = args.iter().map(String::as_str).collect();
    let _ = nm(&refs);
}

fn set_autoconnect(uuid: &str, on: bool) {
    let _ = nm(&[
        "connection",
        "modify",
        uuid,
        "connection.autoconnect",
        if on { "yes" } else { "no" },
    ]);
}
