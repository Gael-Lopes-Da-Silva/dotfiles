#!/usr/bin/env python3

import os
import subprocess

os.environ["GSK_RENDERER"] = "gl"

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
gi.require_version("Gdk", "4.0")

from gi.repository import Adw, Gdk, Gio, GLib, GObject, Gtk, Pango


class ClipboardItem(GObject.Object):
    def __init__(self, item_id, text):
        super().__init__()
        self.item_id = item_id
        self.text = text


def load_clipboard_items():
    try:
        # Runs cliphist list to collect all active history
        res = subprocess.run(
            ["cliphist", "list"], capture_output=True, text=True, check=True
        )
        items = []
        for line in res.stdout.splitlines():
            if "\t" in line:
                parts = line.split("\t", 1)
                items.append(ClipboardItem(parts[0].strip(), parts[1]))
        return items
    except Exception as e:
        print(f"Error loading cliphist history: {e}")
        return []


class ClipboardLauncher(Adw.Application):
    def __init__(self):
        super().__init__(application_id="launcher.clipboard")

    def do_activate(self):
        self.all_items = load_clipboard_items()

        self.window = Adw.ApplicationWindow(application=self)
        self.window.set_default_size(700, 500)
        self.window.set_decorated(False)
        self.window.set_resizable(False)

        # Global layout container
        main_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=12,
            margin_top=12,
            margin_bottom=12,
            margin_start=12,
            margin_end=12,
        )

        # Search box setup
        self.search = Gtk.SearchEntry()
        self.search.set_key_capture_widget(self.window)
        self.search.connect("search-changed", self.on_search)
        self.search.connect("activate", self.on_search_activate)

        # Intercept shortcuts directly inside search entry and master window
        key_controller = Gtk.EventControllerKey()
        key_controller.connect("key-pressed", self.on_key_pressed)
        self.window.add_controller(key_controller)

        search_key_controller = Gtk.EventControllerKey()
        search_key_controller.connect("key-pressed", self.on_key_pressed)
        self.search.add_controller(search_key_controller)

        main_box.append(self.search)

        # Data store and list setup
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
                margin_top=10,
                margin_bottom=10,
                margin_start=12,
                margin_end=12,
            )
            icon = Gtk.Image.new_from_icon_name("edit-copy-symbolic")
            label = Gtk.Label(xalign=0)
            label.set_ellipsize(Pango.EllipsizeMode.END)
            label.set_hexpand(True)

            box.append(icon)
            box.append(label)
            item.set_child(box)

            gesture = Gtk.GestureClick()
            gesture.connect("released", on_row_clicked, item)
            box.add_controller(gesture)

        def bind(_, item):
            item_obj = item.get_item()
            box = item.get_child()
            label = box.get_last_child()
            # Replace newlines with spaces for a single line preview
            clean_text = item_obj.text.replace("\n", " ").strip()
            label.set_text(clean_text)

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

        # Help context footer showing active map keys
        footer_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        help_label = Gtk.Label(xalign=0)
        help_label.set_markup(
            "<span size='small' foreground='#888888'>"
            "<b>Enter</b> Copy | <b>Ctrl+D</b> Delete | "
            "<b>Ctrl+Q</b> Query Delete | <b>Ctrl+C</b> Clear History"
            "</span>"
        )
        footer_box.append(help_label)
        main_box.append(footer_box)

        self.window.set_content(main_box)
        self.window.present()
        self.search.grab_focus()

    def reload_store_view(self):
        """Refreshes the displayed items matching current text filter input"""
        text = self.search.get_text().lower()
        self.store.remove_all()
        for item in self.all_items:
            if text in item.text.lower():
                self.store.append(item)

    def on_key_pressed(self, controller, keyval, keycode, state):
        if keyval == Gdk.KEY_Escape:
            self.quit()
            return True

        # Check for Ctrl modifier actions
        is_ctrl = (state & Gdk.ModifierType.CONTROL_MASK) != 0
        if is_ctrl:
            if keyval == Gdk.KEY_d:
                self.action_delete_selected()
                return True
            elif keyval == Gdk.KEY_q:
                self.action_delete_by_query()
                return True
            elif keyval == Gdk.KEY_c:
                self.action_clear_all()
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

    def on_activate(self, _list_view, position):
        item = self.store.get_item(position)
        if not item:
            return

        try:
            # Replicates: cliphist decode | wl-copy
            decode_proc = subprocess.Popen(
                ["cliphist", "decode", item.item_id], stdout=subprocess.PIPE
            )
            subprocess.run(["wl-copy"], stdin=decode_proc.stdout, check=True)
            self.send_notification(
                "Clipboard history", "You can paste the copy from the clipboard entry."
            )
            GLib.timeout_add(100, self.quit_app)
        except Exception as e:
            print(f"Failed to write to system clipboard: {e}")

    # --- Actions and Modals ---

    def action_delete_selected(self):
        position = self.selection.get_selected()
        if position == Gtk.INVALID_LIST_POSITION or self.store.get_n_items() == 0:
            return

        item = self.store.get_item(position)

        dialog = Adw.MessageDialog(
            transient_for=self.window,
            heading="Delete Entry?",
            body="Do you really want to delete this entry from your clipboard history?",
        )
        dialog.add_response("cancel", "Cancel")
        dialog.add_response("delete", "Delete")
        dialog.set_response_appearance("delete", Adw.ResponseAppearance.DESTRUCTIVE)

        def handle_response(_, response_id):
            if response_id == "delete":
                proc = subprocess.Popen(
                    ["cliphist", "delete"], stdin=subprocess.PIPE, text=True
                )
                proc.communicate(input=f"{item.item_id}\t{item.text}")
                self.send_notification(
                    "Clipboard history", "Entry successfully deleted."
                )
                self.refresh_data()

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
        """Forces data structural rebuild and refreshes UI layer updates"""
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
