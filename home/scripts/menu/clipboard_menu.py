#!/usr/bin/env python3

import os
import subprocess

os.environ["GSK_RENDERER"] = "gl"

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
gi.require_version("Gdk", "4.0")
gi.require_version("GdkPixbuf", "2.0")

from gi.repository import Adw, Gdk, GdkPixbuf, Gio, GLib, GObject, Gtk, Pango


class ClipboardItem(GObject.Object):
    def __init__(self, item_id, text):
        super().__init__()
        self.item_id = item_id
        self.text = text
        self.is_image = "binary data" in text.lower()


def load_clipboard_items():
    try:
        res = subprocess.run(
            ["cliphist", "list"], capture_output=True, text=True, check=True
        )
        items = []
        for line in res.stdout.splitlines():
            if "\t" in line:
                parts = line.split("\t", 1)
                item_text = parts[1]

                if "<meta http-equiv" in item_text.lower():
                    continue

                items.append(ClipboardItem(parts[0].strip(), item_text))
        return items
    except Exception:
        return []


class ClipboardLauncher(Adw.Application):
    def __init__(self):
        super().__init__(application_id="launcher.clipboard")
        self.window = None

    def do_activate(self):
        if self.window:
            self.window.present()
            self.search.grab_focus()
            return

        self.all_items = load_clipboard_items()

        self.window = Adw.ApplicationWindow(application=self)
        self.window.set_default_size(700, 500)
        self.window.set_decorated(False)
        self.window.set_resizable(False)

        main_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=12,
            margin_top=6,
            margin_bottom=6,
            margin_start=6,
            margin_end=6,
        )

        header = Adw.HeaderBar()
        header.set_show_title(True)
        header.set_show_start_title_buttons(False)
        header.set_show_end_title_buttons(True)
        header.add_css_class("flat")

        self.search = Gtk.SearchEntry()
        self.search.set_hexpand(True)
        self.search.set_key_capture_widget(self.window)
        self.search.connect("search-changed", self.on_search)
        self.search.connect("activate", self.on_search_activate)

        key_controller = Gtk.EventControllerKey()
        key_controller.connect("key-pressed", self.on_key_pressed)
        self.window.add_controller(key_controller)

        search_key_controller = Gtk.EventControllerKey()
        search_key_controller.connect("key-pressed", self.on_key_pressed)
        self.search.add_controller(search_key_controller)

        header.set_title_widget(self.search)
        main_box.append(header)

        self.store = Gio.ListStore(item_type=ClipboardItem)
        self.selection = Gtk.SingleSelection(model=self.store)

        self.reload_store_view()

        factory = Gtk.SignalListItemFactory()

        def on_row_clicked(gesture, n_press, x, y, item):
            if n_press == 1:
                position = item.get_position()
                if position != Gtk.INVALID_LIST_POSITION:
                    self.selection.set_selected(position)
                    self.on_activate(self.view, position)

        def setup(_, item):
            box = Gtk.Box(
                orientation=Gtk.Orientation.HORIZONTAL,
                spacing=12,
                margin_top=6,
                margin_bottom=6,
                margin_start=12,
                margin_end=12,
            )

            content_area = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=12)

            box.append(content_area)
            item.set_child(box)

            gesture = Gtk.GestureClick()
            gesture.connect("released", on_row_clicked, item)
            content_area.add_controller(gesture)

        def bind(_, item):
            item_obj = item.get_item()
            box = item.get_child()
            content_area = box.get_first_child()

            while box.get_last_child() != content_area:
                box.remove(box.get_last_child())

            while child := content_area.get_first_child():
                content_area.remove(child)

            icon = Gtk.Image.new_from_icon_name("edit-copy-symbolic")
            icon.set_valign(Gtk.Align.CENTER)
            content_area.append(icon)

            if getattr(item_obj, "is_image", False):
                img_widget = Gtk.Image()
                img_widget.set_pixel_size(80)
                img_widget.set_hexpand(True)
                img_widget.set_halign(Gtk.Align.START)

                try:
                    res = subprocess.run(
                        ["cliphist", "decode", item_obj.item_id],
                        capture_output=True,
                        check=True,
                    )
                    loader = GdkPixbuf.PixbufLoader()
                    loader.write(res.stdout)
                    loader.close()

                    pixbuf = loader.get_pixbuf()
                    if pixbuf:
                        texture = Gdk.Texture.new_for_pixbuf(pixbuf)
                        img_widget.set_from_paintable(texture)
                    else:
                        img_widget.set_from_icon_name("image-missing-symbolic")
                except Exception:
                    img_widget.set_from_icon_name("image-missing-symbolic")

                content_area.append(img_widget)
            else:
                label = Gtk.Label(xalign=0)
                label.set_ellipsize(Pango.EllipsizeMode.END)
                label.set_hexpand(True)
                label.set_valign(Gtk.Align.CENTER)

                clean_text = item_obj.text.replace("\n", " ").strip()
                label.set_text(clean_text)

                content_area.append(label)

            copy_btn = Gtk.Button.new_from_icon_name("edit-copy-symbolic")
            copy_btn.set_tooltip_text("Copy to Clipboard")
            copy_btn.set_valign(Gtk.Align.CENTER)
            copy_btn.connect(
                "clicked", lambda _: self.on_activate(None, item.get_position())
            )

            del_btn = Gtk.Button.new_from_icon_name("user-trash-symbolic")
            del_btn.add_css_class("destructive-action")
            del_btn.set_tooltip_text("Delete")
            del_btn.set_valign(Gtk.Align.CENTER)
            del_btn.connect("clicked", lambda _: self.action_delete_item(item_obj))

            btn_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
            btn_box.append(copy_btn)
            btn_box.append(del_btn)
            box.append(btn_box)

        factory.connect("setup", setup)
        factory.connect("bind", bind)

        self.view = Gtk.ListView(
            model=self.selection,
            factory=factory,
            single_click_activate=False,
        )
        self.view.connect("activate", self.on_activate)
        self.view.add_css_class("navigation-sidebar")

        scrolled = Gtk.ScrolledWindow()
        scrolled.set_child(self.view)
        scrolled.set_vexpand(True)
        main_box.append(scrolled)

        footer_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)

        clear_history_btn = Gtk.Button(label="Clear History")
        clear_history_btn.add_css_class("destructive-action")
        clear_history_btn.connect("clicked", lambda _: self.action_clear_all())

        query_clear_btn = Gtk.Button(label="Query Clear")
        query_clear_btn.connect("clicked", lambda _: self.action_delete_by_query())

        spacer = Gtk.Box(hexpand=True)

        copy_btn = Gtk.Button(label="Copy")
        copy_btn.add_css_class("suggested-action")
        copy_btn.connect("clicked", self.on_copy_footer_clicked)

        footer_box.append(clear_history_btn)
        footer_box.append(query_clear_btn)
        footer_box.append(spacer)
        footer_box.append(copy_btn)

        main_box.append(footer_box)

        self.window.set_content(main_box)
        self.window.present()
        self.search.grab_focus()

    def reload_store_view(self):
        text = self.search.get_text().lower()
        self.store.remove_all()
        for item in self.all_items:
            if text in item.text.lower():
                self.store.append(item)

    def on_key_pressed(self, controller, keyval, keycode, state):
        if keyval == Gdk.KEY_Escape:
            self.quit()
            return True
        return False

    def on_search(self, entry):
        self.reload_store_view()
        if not entry.has_focus():
            GLib.idle_add(self.grab_search_focus)

    def grab_search_focus(self):
        self.search.grab_focus()
        self.search.set_position(-1)
        return GLib.SOURCE_REMOVE

    def on_search_activate(self, entry):
        if self.store.get_n_items() > 0:
            self.on_activate(self.view, 0)

    def on_copy_footer_clicked(self, button):
        position = self.selection.get_selected()
        if position != Gtk.INVALID_LIST_POSITION and self.store.get_n_items() > 0:
            self.on_activate(self.view, position)

    def on_activate(self, _list_view, position):
        item = self.store.get_item(position)
        if not item:
            return

        try:
            decode_proc = subprocess.Popen(
                ["cliphist", "decode", item.item_id], stdout=subprocess.PIPE
            )
            subprocess.run(["wl-copy"], stdin=decode_proc.stdout, check=True)
            self.send_notification(
                "Clipboard history", "Item copied to the system clipboard."
            )
        except Exception as e:
            print(f"Failed to write to system clipboard: {e}")

    def action_delete_item(self, item):
        dialog = Adw.MessageDialog(
            transient_for=self.window,
            heading="Delete Item",
            body="Are you sure you want to delete this item from your history?",
        )
        dialog.add_response("cancel", "Cancel")
        dialog.add_response("delete", "Delete")
        dialog.set_response_appearance("delete", Adw.ResponseAppearance.DESTRUCTIVE)

        def handle_response(_, response_id):
            if response_id == "delete":
                try:
                    proc = subprocess.Popen(
                        ["cliphist", "delete"], stdin=subprocess.PIPE, text=True
                    )
                    proc.communicate(input=f"{item.item_id}\t{item.text}")
                    self.send_notification(
                        "Clipboard history", "Entry successfully deleted."
                    )
                    self.refresh_data()
                except Exception as e:
                    print(f"Failed to delete item: {e}")

        dialog.connect("response", handle_response)
        dialog.present()

    def action_delete_by_query(self):
        dialog = Adw.MessageDialog(
            transient_for=self.window,
            heading="Delete by Query",
            body="Enter a search term. Every history item matching this string will be wiped:",
        )

        entry = Gtk.Entry(placeholder_text="Type pattern query here...")
        dialog.set_extra_child(entry)

        dialog.add_response("cancel", "Cancel")
        dialog.add_response("delete", "Delete All")
        dialog.set_response_appearance("delete", Adw.ResponseAppearance.DESTRUCTIVE)

        def handle_response(_, response_id):
            query = entry.get_text().strip()
            if response_id == "delete" and query:
                subprocess.run(["cliphist", "delete-query", query], check=True)
                self.send_notification(
                    "Clipboard history", f"Deleted all entries matching '{query}'."
                )
                self.refresh_data()

        dialog.connect("response", handle_response)
        dialog.present()

    def action_clear_all(self):
        dialog = Adw.MessageDialog(
            transient_for=self.window,
            heading="Clear Clipboard History?",
            body="This will completely clear your history. This change is irreversible.",
        )
        dialog.add_response("cancel", "Cancel")
        dialog.add_response("clear", "Clear All History")
        dialog.set_response_appearance("clear", Adw.ResponseAppearance.DESTRUCTIVE)

        def handle_response(_, response_id):
            if response_id == "clear":
                subprocess.run(["cliphist", "wipe"], check=True)
                self.send_notification(
                    "Clipboard history",
                    "The clipboard history was successfully cleared.",
                )
                self.refresh_data()

        dialog.connect("response", handle_response)
        dialog.present()

    def refresh_data(self):
        self.all_items = load_clipboard_items()
        self.reload_store_view()
        GLib.idle_add(self.grab_search_focus)

    def send_notification(self, title, message):
        try:
            subprocess.run(
                ["notify-send", "-a", "notification", "-t", "5000", title, message]
            )
        except Exception as e:
            print(f"Notification error: {e}")

    def quit_app(self):
        self.quit()
        return GLib.SOURCE_REMOVE


if __name__ == "__main__":
    app = ClipboardLauncher()
    app.run()
