mod power_action;

use std::cell::RefCell;
use std::process::Command;
use std::rc::Rc;

use component::Component;
use gtk4::gdk;
use gtk4::gio;
use gtk4::glib;
use gtk4::prelude::*;
use gtk4::{self as gtk, GestureClick};
use libadwaita as adw;
use libadwaita::prelude::*;
use power_action::PowerAction;

pub fn component() -> Component {
    Component {
        id: "power",
        title: "Power",
        icon: "system-shutdown-symbolic",
        build: build,
    }
}

fn build() -> gtk::Widget {
    let actions = load_power_actions();

    let store = gio::ListStore::new::<PowerAction>();
    for action in &actions {
        store.append(action);
    }

    let query = Rc::new(RefCell::new(String::new()));
    let filter = gtk::CustomFilter::new(glib::clone!(
        #[strong]
        query,
        move |obj| {
            let q = query.borrow();
            if q.is_empty() {
                return true;
            }
            obj.downcast_ref::<PowerAction>()
                .map(|action| action.name().to_lowercase().contains(q.as_str()))
                .unwrap_or(false)
        }
    ));

    let filter_model = gtk::FilterListModel::new(Some(store), Some(filter.clone()));
    let selection = gtk::SingleSelection::new(Some(filter_model));
    if selection.n_items() > 0 {
        selection.set_selected(0);
    }

    let factory = gtk::SignalListItemFactory::new();
    factory.connect_setup(move |_, item| {
        let list_item = item
            .downcast_ref::<gtk::ListItem>()
            .expect("ListItem in setup");

        let row = gtk::Box::builder()
            .orientation(gtk::Orientation::Horizontal)
            .spacing(12)
            .margin_top(10)
            .margin_bottom(10)
            .margin_start(12)
            .margin_end(12)
            .build();

        let icon = gtk::Image::builder().pixel_size(24).build();
        let label = gtk::Label::builder().xalign(0.0).hexpand(true).build();

        row.append(&icon);
        row.append(&label);
        list_item.set_child(Some(&row));

        let gesture = GestureClick::new();
        gesture.connect_released(glib::clone!(
            #[weak]
            list_item,
            move |_, n_press, _, _| {
                if n_press != 1 {
                    return;
                }
                let Some(widget) = list_item.child() else {
                    return;
                };
                if let Some(action) = list_item.item().and_downcast::<PowerAction>() {
                    confirm_action(&widget, &action);
                }
            }
        ));
        row.add_controller(gesture);
    });

    factory.connect_bind(move |_, item| {
        let list_item = item
            .downcast_ref::<gtk::ListItem>()
            .expect("ListItem in bind");
        let Some(action) = list_item.item().and_downcast::<PowerAction>() else {
            return;
        };
        let Some(row) = list_item.child().and_downcast::<gtk::Box>() else {
            return;
        };

        let icon = row
            .first_child()
            .and_downcast::<gtk::Image>()
            .expect("icon image");
        let label = row
            .last_child()
            .and_downcast::<gtk::Label>()
            .expect("name label");

        icon.set_icon_name(Some(&resolve_icon(action.icon_names())));
        label.set_text(action.name());
    });

    let view = gtk::ListView::builder()
        .model(&selection)
        .factory(&factory)
        .single_click_activate(false)
        .css_classes(["navigation-sidebar"])
        .build();

    view.connect_activate(glib::clone!(
        #[weak]
        selection,
        #[weak]
        view,
        move |_, position| {
            if let Some(action) = selection.item(position).and_downcast::<PowerAction>() {
                confirm_action(&view, &action);
            }
        }
    ));

    let search = gtk::SearchEntry::builder().hexpand(true).build();

    search.connect_search_changed(glib::clone!(
        #[strong]
        query,
        #[weak]
        filter,
        #[weak]
        selection,
        #[weak]
        search,
        move |entry| {
            *query.borrow_mut() = entry.text().to_lowercase();
            filter.changed(gtk::FilterChange::Different);
            if selection.n_items() > 0 {
                selection.set_selected(0);
            }
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
        #[weak]
        search,
        move |_| {
            activate_selected(&selection, &search);
        }
    ));

    let key_controller = gtk::EventControllerKey::new();
    key_controller.connect_key_pressed(glib::clone!(
        #[weak]
        selection,
        #[weak]
        view,
        #[upgrade_or]
        glib::Propagation::Proceed,
        move |_, key, _, _| handle_nav_key(key, &selection, &view)
    ));
    search.add_controller(key_controller);

    let scrolled = gtk::ScrolledWindow::builder()
        .child(&view)
        .vexpand(true)
        .build();

    let page = gtk::Box::builder()
        .orientation(gtk::Orientation::Vertical)
        .spacing(12)
        .margin_top(6)
        .margin_bottom(6)
        .margin_start(6)
        .margin_end(6)
        .build();

    page.append(&search);
    page.append(&scrolled);

    search.set_key_capture_widget(Some(&page));

    page.connect_map(glib::clone!(
        #[weak]
        search,
        move |_| {
            search.grab_focus();
            search.set_position(-1);
        }
    ));

    page.upcast()
}

fn handle_nav_key(
    key: gdk::Key,
    selection: &gtk::SingleSelection,
    view: &gtk::ListView,
) -> glib::Propagation {
    if key == gdk::Key::Down {
        move_selection(selection, view, 1);
        return glib::Propagation::Stop;
    }
    if key == gdk::Key::Up {
        move_selection(selection, view, -1);
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

fn activate_selected(selection: &gtk::SingleSelection, parent: &impl IsA<gtk::Widget>) {
    let position = selection.selected();
    if position == gtk::INVALID_LIST_POSITION || selection.n_items() == 0 {
        return;
    }
    if let Some(action) = selection.item(position).and_downcast::<PowerAction>() {
        confirm_action(parent, &action);
    }
}

fn confirm_action(parent: &impl IsA<gtk::Widget>, action: &PowerAction) {
    let dialog = adw::AlertDialog::new(
        Some("Confirm System Action"),
        Some(&format!(
            "Do you really want to execute this action: {}?",
            action.name()
        )),
    );

    dialog.add_response("cancel", "Cancel");
    dialog.add_response("execute", action.name());
    dialog.set_response_appearance(
        "execute",
        if action.is_destructive() {
            adw::ResponseAppearance::Destructive
        } else {
            adw::ResponseAppearance::Suggested
        },
    );
    dialog.set_close_response("cancel");
    dialog.set_default_response(Some("cancel"));

    let action = action.clone();
    dialog.choose(Some(parent), None::<&gio::Cancellable>, move |response| {
        if response != "execute" {
            return;
        }
        run_action(&action);
    });
}

fn run_action(action: &PowerAction) {
    let command = action.command();
    if command.is_empty() {
        return;
    }

    match Command::new(&command[0]).args(&command[1..]).spawn() {
        Ok(_) => {
            if let Some(app) = gio::Application::default() {
                app.quit();
            }
        }
        Err(err) => eprintln!("Failed to execute {}: {err}", action.name()),
    }
}

fn resolve_icon(icon_names: &[&str]) -> String {
    let theme = gdk::Display::default().map(|display| gtk::IconTheme::for_display(&display));

    if let Some(theme) = theme {
        for name in icon_names {
            if theme.has_icon(name) {
                return (*name).to_string();
            }
        }
    }

    "image-missing-symbolic".to_string()
}

fn load_power_actions() -> Vec<PowerAction> {
    let current_user = std::env::var("USER").unwrap_or_default();

    vec![
        PowerAction::new(
            "Shutdown",
            &["systemctl", "poweroff"],
            &["system-shutdown-symbolic"],
        ),
        PowerAction::new(
            "Reboot",
            &["systemctl", "reboot"],
            &["system-restart-symbolic", "system-reboot-symbolic"],
        ),
        PowerAction::new(
            "Suspend",
            &["systemctl", "suspend"],
            &[
                "system-suspend-symbolic",
                "night-light-symbolic",
                "weather-night-symbolic",
                "media-playback-pause-symbolic",
            ],
        ),
        PowerAction::new(
            "Hibernate",
            &["systemctl", "hibernate"],
            &[
                "system-hibernate-symbolic",
                "media-playback-pause-symbolic",
                "night-light-symbolic",
            ],
        ),
        PowerAction::new(
            "Logout",
            &["loginctl", "terminate-user", &current_user],
            &["system-log-out-symbolic", "application-exit-symbolic"],
        ),
        PowerAction::new(
            "Lock",
            &["loginctl", "lock-session"],
            &["system-lock-screen-symbolic", "changes-prevent-symbolic"],
        ),
    ]
}
