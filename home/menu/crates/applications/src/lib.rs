mod app_item;

use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

use app_item::AppItem;
use component::{Component, defer_idle};
use gtk4::gdk;
use gtk4::gio;
use gtk4::glib;
use gtk4::prelude::*;
use gtk4::{self as gtk, GestureClick};

pub fn component() -> Component {
    Component {
        id: "applications",
        title: "Applications",
        icon: "view-app-grid-symbolic",
        build,
    }
}

fn build() -> gtk::Widget {
    let store = gio::ListStore::new::<AppItem>();

    let query = Rc::new(RefCell::new(String::new()));
    let filter = gtk::CustomFilter::new(glib::clone!(
        #[strong]
        query,
        move |obj| {
            let q = query.borrow();
            if q.is_empty() {
                return true;
            }
            obj.downcast_ref::<AppItem>()
                .map(|item| item.name().to_lowercase().contains(q.as_str()))
                .unwrap_or(false)
        }
    ));

    let filter_model = gtk::FilterListModel::new(Some(store.clone()), Some(filter.clone()));
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

        let icon = gtk::Image::builder().pixel_size(32).build();
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
                let position = list_item.position();
                if position == gtk::INVALID_LIST_POSITION {
                    return;
                }
                if let Some(item) = list_item.item().and_downcast::<AppItem>() {
                    launch_app(&item);
                }
            }
        ));
        row.add_controller(gesture);
    });

    factory.connect_bind(move |_, item| {
        let list_item = item
            .downcast_ref::<gtk::ListItem>()
            .expect("ListItem in bind");
        let Some(app) = list_item.item().and_downcast::<AppItem>() else {
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

        match app.app_info().icon() {
            Some(gicon) => icon.set_from_gicon(&gicon),
            None => icon.set_icon_name(Some("application-x-executable")),
        }
        label.set_text(&app.name());
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
        move |_, position| {
            if let Some(item) = selection.item(position).and_downcast::<AppItem>() {
                launch_app(&item);
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
        move |_| {
            activate_selected(&selection);
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

    let loading = gtk::Spinner::builder()
        .margin_top(12)
        .halign(gtk::Align::Center)
        .build();
    loading.start();
    page.prepend(&loading);

    defer_idle(glib::clone!(
        #[strong]
        store,
        #[weak]
        selection,
        #[weak]
        loading,
        move || {
            let apps = load_apps();
            for app in &apps {
                store.append(app);
            }
            if selection.n_items() > 0 {
                selection.set_selected(0);
            }
            loading.stop();
            loading.set_visible(false);
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

fn activate_selected(selection: &gtk::SingleSelection) {
    let position = selection.selected();
    if position == gtk::INVALID_LIST_POSITION || selection.n_items() == 0 {
        return;
    }
    if let Some(item) = selection.item(position).and_downcast::<AppItem>() {
        launch_app(&item);
    }
}

fn launch_app(item: &AppItem) {
    let app_info = item.app_info();
    let context = gdk::Display::default().map(|display| display.app_launch_context());

    if let Err(err) = app_info.launch(&[] as &[gio::File], context.as_ref()) {
        eprintln!("Failed to launch {}: {err}", item.name());
        return;
    }

    if let Some(app) = gio::Application::default() {
        app.quit();
    }
}

fn load_apps() -> Vec<AppItem> {
    let mut by_name = HashMap::new();

    for app_info in gio::AppInfo::all() {
        if !app_info.should_show() {
            continue;
        }
        let name = app_info.name();
        if name.is_empty() {
            continue;
        }
        by_name.insert(name.to_string(), AppItem::new(app_info));
    }

    let mut apps: Vec<_> = by_name.into_values().collect();
    apps.sort_by_key(|app| app.name().to_lowercase());
    apps
}
