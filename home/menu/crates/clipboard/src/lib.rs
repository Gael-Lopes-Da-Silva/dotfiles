mod clipboard_item;

use std::cell::RefCell;
use std::io::Write;
use std::process::{Command, Stdio};
use std::rc::Rc;

use clipboard_item::{ClipboardItem, ClipboardItemData};
use component::{Component, spawn_background};
use gtk4::gdk;
use gtk4::gio;
use gtk4::glib;
use gtk4::pango;
use gtk4::prelude::*;
use gtk4::{self as gtk, GestureClick};
use libadwaita as adw;
use libadwaita::prelude::*;

pub fn component() -> Component {
    Component {
        id: "clipboard",
        title: "Clipboard",
        icon: "edit-copy-symbolic",
        build,
    }
}

fn build() -> gtk::Widget {
    let store = gio::ListStore::new::<ClipboardItem>();

    let query = Rc::new(RefCell::new(String::new()));
    let filter = gtk::CustomFilter::new(glib::clone!(
        #[strong]
        query,
        move |obj| {
            let q = query.borrow();
            if q.is_empty() {
                return true;
            }
            obj.downcast_ref::<ClipboardItem>()
                .map(|item| item.text().to_lowercase().contains(q.as_str()))
                .unwrap_or(false)
        }
    ));

    let filter_model = gtk::FilterListModel::new(Some(store.clone()), Some(filter.clone()));
    let selection = gtk::SingleSelection::new(Some(filter_model));
    if selection.n_items() > 0 {
        selection.set_selected(0);
    }

    let search = gtk::SearchEntry::builder().hexpand(true).build();

    let refresh: Rc<dyn Fn()> = Rc::new(glib::clone!(
        #[weak]
        store,
        #[weak]
        selection,
        #[weak]
        search,
        move || {
            refresh_ui(&store, &selection, &search);
        }
    ));

    let factory = gtk::SignalListItemFactory::new();
    factory.connect_setup(glib::clone!(
        #[strong]
        refresh,
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

            let content_area = gtk::Box::builder()
                .orientation(gtk::Orientation::Horizontal)
                .spacing(12)
                .hexpand(true)
                .build();

            let copy_btn = gtk::Button::from_icon_name("edit-copy-symbolic");
            copy_btn.set_tooltip_text(Some("Copy to Clipboard"));
            copy_btn.set_valign(gtk::Align::Center);

            let del_btn = gtk::Button::from_icon_name("user-trash-symbolic");
            del_btn.add_css_class("destructive-action");
            del_btn.set_tooltip_text(Some("Delete"));
            del_btn.set_valign(gtk::Align::Center);

            let btn_box = gtk::Box::builder()
                .orientation(gtk::Orientation::Horizontal)
                .spacing(4)
                .build();
            btn_box.append(&copy_btn);
            btn_box.append(&del_btn);

            row.append(&content_area);
            row.append(&btn_box);
            list_item.set_child(Some(&row));

            let gesture = GestureClick::new();
            gesture.connect_released(glib::clone!(
                #[weak]
                list_item,
                move |_, n_press, _, _| {
                    if n_press != 1 {
                        return;
                    }
                    if let Some(item) = list_item.item().and_downcast::<ClipboardItem>() {
                        copy_item(&item);
                    }
                }
            ));
            content_area.add_controller(gesture);

            copy_btn.connect_clicked(glib::clone!(
                #[weak]
                list_item,
                move |_| {
                    if let Some(item) = list_item.item().and_downcast::<ClipboardItem>() {
                        copy_item(&item);
                    }
                }
            ));

            del_btn.connect_clicked(glib::clone!(
                #[weak]
                list_item,
                #[strong]
                refresh,
                move |btn| {
                    if let Some(item) = list_item.item().and_downcast::<ClipboardItem>() {
                        confirm_delete_item(btn, &item, refresh.clone());
                    }
                }
            ));
        }
    ));

    factory.connect_bind(move |_, item| {
        let list_item = item
            .downcast_ref::<gtk::ListItem>()
            .expect("ListItem in bind");
        let Some(clip) = list_item.item().and_downcast::<ClipboardItem>() else {
            return;
        };
        let Some(row) = list_item.child().and_downcast::<gtk::Box>() else {
            return;
        };
        let Some(content_area) = row.first_child().and_downcast::<gtk::Box>() else {
            return;
        };

        while let Some(child) = content_area.first_child() {
            content_area.remove(&child);
        }

        let icon = gtk::Image::from_icon_name("edit-copy-symbolic");
        icon.set_valign(gtk::Align::Center);
        content_area.append(&icon);

        if clip.is_image() {
            let img = gtk::Image::builder()
                .pixel_size(80)
                .hexpand(true)
                .halign(gtk::Align::Start)
                .icon_name("image-x-generic-symbolic")
                .build();
            content_area.append(&img);

            let item_id = clip.item_id().to_string();
            let img_w = img.downgrade();
            spawn_background(
                move || load_image_bytes(&item_id),
                move |bytes| {
                    let Some(img) = img_w.upgrade() else {
                        return;
                    };
                    match bytes
                        .and_then(|b| gdk::Texture::from_bytes(&glib::Bytes::from_owned(b)).ok())
                    {
                        Some(texture) => img.set_paintable(Some(&texture)),
                        None => img.set_icon_name(Some("image-missing-symbolic")),
                    }
                },
            );
        } else {
            let clean_text = clip.text().replace('\n', " ").trim().to_string();
            let label = gtk::Label::builder()
                .label(&clean_text)
                .xalign(0.0)
                .hexpand(true)
                .valign(gtk::Align::Center)
                .ellipsize(pango::EllipsizeMode::End)
                .build();
            content_area.append(&label);
        }
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
            if let Some(item) = selection.item(position).and_downcast::<ClipboardItem>() {
                copy_item(&item);
            }
        }
    ));

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

    let clear_history_btn = gtk::Button::from_icon_name("edit-clear-all-symbolic");
    clear_history_btn.add_css_class("destructive-action");
    clear_history_btn.set_tooltip_text(Some("Clear history"));
    clear_history_btn.connect_clicked(glib::clone!(
        #[strong]
        refresh,
        move |btn| {
            confirm_clear_all(btn, refresh.clone());
        }
    ));

    let spacer = gtk::Box::builder().hexpand(true).build();

    let copy_footer_btn = gtk::Button::with_label("Copy");
    copy_footer_btn.add_css_class("suggested-action");
    copy_footer_btn.connect_clicked(glib::clone!(
        #[weak]
        selection,
        move |_| {
            activate_selected(&selection);
        }
    ));

    let footer = gtk::Box::builder()
        .orientation(gtk::Orientation::Horizontal)
        .spacing(8)
        .build();
    footer.append(&clear_history_btn);
    footer.append(&spacer);
    footer.append(&copy_footer_btn);

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

    let loading = gtk::Spinner::builder()
        .margin_top(12)
        .halign(gtk::Align::Center)
        .build();
    loading.start();
    page.prepend(&loading);

    spawn_background(
        load_clipboard_item_data,
        glib::clone!(
            #[strong]
            store,
            #[weak]
            selection,
            #[weak]
            loading,
            move |items| {
                for data in items {
                    store.append(&ClipboardItem::from_data(&data));
                }
                if selection.n_items() > 0 {
                    selection.set_selected(0);
                }
                loading.stop();
                loading.set_visible(false);
            }
        ),
    );

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
    if let Some(item) = selection.item(position).and_downcast::<ClipboardItem>() {
        copy_item(&item);
    }
}

fn copy_item(item: &ClipboardItem) {
    let mut decode = match Command::new("cliphist")
        .args(["decode", item.item_id()])
        .stdout(Stdio::piped())
        .spawn()
    {
        Ok(child) => child,
        Err(err) => {
            eprintln!("Failed to decode clipboard item: {err}");
            return;
        }
    };

    let stdout = match decode.stdout.take() {
        Some(stdout) => stdout,
        None => {
            eprintln!("Failed to capture cliphist decode output");
            return;
        }
    };

    match Command::new("wl-copy").stdin(Stdio::from(stdout)).status() {
        Ok(status) if status.success() => {
            notify("Clipboard history", "Item copied to the system clipboard.");
        }
        Ok(_) | Err(_) => eprintln!("Failed to write to system clipboard"),
    }

    let _ = decode.wait();
}

fn confirm_delete_item(
    parent: &impl IsA<gtk::Widget>,
    item: &ClipboardItem,
    refresh: Rc<dyn Fn()>,
) {
    let dialog = adw::AlertDialog::new(
        Some("Delete Item"),
        Some("Are you sure you want to delete this item from your history?"),
    );

    dialog.add_response("cancel", "Cancel");
    dialog.add_response("delete", "Delete");
    dialog.set_response_appearance("delete", adw::ResponseAppearance::Destructive);
    dialog.set_close_response("cancel");
    dialog.set_default_response(Some("cancel"));

    let item = item.clone();
    dialog.choose(Some(parent), None::<&gio::Cancellable>, move |response| {
        if response != "delete" {
            return;
        }
        if delete_item(&item) {
            notify("Clipboard history", "Entry successfully deleted.");
            refresh();
        }
    });
}

fn confirm_clear_all(parent: &impl IsA<gtk::Widget>, refresh: Rc<dyn Fn()>) {
    let dialog = adw::AlertDialog::new(
        Some("Clear Clipboard History?"),
        Some("This will completely clear your history. This change is irreversible."),
    );

    dialog.add_response("cancel", "Cancel");
    dialog.add_response("clear", "Clear All History");
    dialog.set_response_appearance("clear", adw::ResponseAppearance::Destructive);
    dialog.set_close_response("cancel");
    dialog.set_default_response(Some("cancel"));

    dialog.choose(Some(parent), None::<&gio::Cancellable>, move |response| {
        if response != "clear" {
            return;
        }
        if let Err(err) = Command::new("cliphist").arg("wipe").status() {
            eprintln!("Failed to wipe clipboard history: {err}");
            return;
        }
        notify(
            "Clipboard history",
            "The clipboard history was successfully cleared.",
        );
        refresh();
    });
}

fn delete_item(item: &ClipboardItem) -> bool {
    let mut child = match Command::new("cliphist")
        .arg("delete")
        .stdin(Stdio::piped())
        .spawn()
    {
        Ok(child) => child,
        Err(err) => {
            eprintln!("Failed to delete clipboard item: {err}");
            return false;
        }
    };

    if let Some(mut stdin) = child.stdin.take()
        && let Err(err) = write!(stdin, "{}\t{}", item.item_id(), item.text())
    {
        eprintln!("Failed to write delete payload: {err}");
        return false;
    }

    match child.wait() {
        Ok(status) if status.success() => true,
        Ok(_) | Err(_) => {
            eprintln!("Failed to delete clipboard item");
            false
        }
    }
}

fn refresh_ui(store: &gio::ListStore, selection: &gtk::SingleSelection, search: &gtk::SearchEntry) {
    spawn_background(
        load_clipboard_item_data,
        glib::clone!(
            #[strong]
            store,
            #[weak]
            selection,
            #[weak]
            search,
            move |items| {
                store.remove_all();
                for data in items {
                    store.append(&ClipboardItem::from_data(&data));
                }
                if selection.n_items() > 0 {
                    selection.set_selected(0);
                }
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

fn load_image_bytes(item_id: &str) -> Option<Vec<u8>> {
    let output = Command::new("cliphist")
        .args(["decode", item_id])
        .output()
        .ok()?;
    if !output.status.success() {
        return None;
    }
    Some(output.stdout)
}

fn notify(title: &str, message: &str) {
    if let Err(err) = Command::new("notify-send")
        .args(["-a", "notification", "-t", "5000", title, message])
        .spawn()
    {
        eprintln!("Notification error: {err}");
    }
}

fn load_clipboard_item_data() -> Vec<ClipboardItemData> {
    let output = match Command::new("cliphist").arg("list").output() {
        Ok(output) if output.status.success() => output,
        _ => return Vec::new(),
    };

    let stdout = String::from_utf8_lossy(&output.stdout);
    let mut items = Vec::new();

    for line in stdout.lines() {
        let Some((id, text)) = line.split_once('\t') else {
            continue;
        };
        if text.to_lowercase().contains("<meta http-equiv") {
            continue;
        }
        let text = text.to_string();
        items.push(ClipboardItemData {
            item_id: id.trim().to_string(),
            text: text.clone(),
            is_image: text.to_lowercase().contains("binary data"),
        });
    }

    items
}
