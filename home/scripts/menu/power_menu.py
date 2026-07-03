#!/usr/bin/env python3

import os
import subprocess

os.environ["GSK_RENDERER"] = "gl"

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
gi.require_version("Gdk", "4.0")

from gi.repository import Adw, Gdk, Gio, GLib, GObject, Gtk


class PowerAction(GObject.Object):
    def __init__(self, name, command, icon_names):
        super().__init__()
        self.name = name
        self.command = command
        self.icon_names = icon_names


def load_power_actions():
    current_user = os.environ.get("USER", "")
    return [
        PowerAction(
            "Shutdown", ["systemctl", "poweroff"], ["system-shutdown-symbolic"]
        ),
        PowerAction(
            "Reboot",
            ["systemctl", "reboot"],
            ["system-restart-symbolic", "system-reboot-symbolic"],
        ),
        PowerAction(
            "Suspend",
            ["systemctl", "suspend"],
            [
                "system-suspend-symbolic",
                "night-light-symbolic",
                "weather-night-symbolic",
                "media-playback-pause-symbolic",
            ],
        ),
        PowerAction(
            "Hibernate",
            ["systemctl", "hibernate"],
            [
                "system-hibernate-symbolic",
                "media-playback-pause-symbolic",
                "night-light-symbolic",
            ],
        ),
        PowerAction(
            "Logout",
            ["loginctl", "terminate-user", current_user],
            ["system-log-out-symbolic", "application-exit-symbolic"],
        ),
        PowerAction(
            "Lock",
            ["loginctl", "lock-session"],
            ["system-lock-screen-symbolic", "changes-prevent-symbolic"],
        ),
    ]


class PowerLauncher(Adw.Application):
    def __init__(self):
        super().__init__(application_id="launcher.power")
        self.window = None

    def do_activate(self):
        if self.window:
            self.window.present()
            self.search.grab_focus()
            return

        self.actions = load_power_actions()

        self.window = Adw.ApplicationWindow(application=self)
        self.window.set_default_size(700, 500)
        self.window.set_decorated(False)
        self.window.set_resizable(False)

        main_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=12,
            margin_top=12,
            margin_bottom=12,
            margin_start=12,
            margin_end=12,
        )

        self.search = Gtk.SearchEntry()
        self.search.set_key_capture_widget(self.window)
        self.search.connect("search-changed", self.on_search)
        self.search.connect("activate", self.on_search_activate)

        key_controller = Gtk.EventControllerKey()
        key_controller.connect("key-pressed", self.on_key_pressed)
        self.window.add_controller(key_controller)

        search_key_controller = Gtk.EventControllerKey()
        search_key_controller.connect("key-pressed", self.on_key_pressed)
        self.search.add_controller(search_key_controller)

        main_box.append(self.search)

        self.store = Gio.ListStore(item_type=PowerAction)
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
            icon = Gtk.Image()
            icon.set_pixel_size(24)

            label = Gtk.Label(xalign=0)
            label.set_hexpand(True)

            box.append(icon)
            box.append(label)
            item.set_child(box)

            gesture = Gtk.GestureClick()
            gesture.connect("released", on_row_clicked, item)
            box.add_controller(gesture)

        def bind(_, item):
            action_obj = item.get_item()
            box = item.get_child()
            icon = box.get_first_child()
            label = box.get_last_child()

            chosen_icon = "image-missing-symbolic"
            icon_theme = Gtk.IconTheme.get_for_display(Gdk.Display.get_default())
            for name in action_obj.icon_names:
                if icon_theme.has_icon(name):
                    chosen_icon = name
                    break

            icon.set_from_icon_name(chosen_icon)
            label.set_text(action_obj.name)

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

        footer_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        spacer = Gtk.Box(hexpand=True)

        run_btn = Gtk.Button(label="Run")
        run_btn.add_css_class("suggested-action")
        run_btn.connect("clicked", self.on_run_clicked)

        footer_box.append(spacer)
        footer_box.append(run_btn)
        main_box.append(footer_box)

        self.window.set_content(main_box)
        self.window.present()
        self.search.grab_focus()

    def reload_store_view(self):
        text = self.search.get_text().lower()
        self.store.remove_all()
        for action in self.actions:
            if text in action.name.lower():
                self.store.append(action)

    def on_key_pressed(self, controller, keyval, keycode, state):
        if keyval == Gdk.KEY_Escape:
            self.quit()
            return True

        if keyval in (Gdk.KEY_Tab, Gdk.KEY_ISO_Left_Tab):
            position = self.selection.get_selected()
            if position != Gtk.INVALID_LIST_POSITION and self.store.get_n_items() > 0:
                action_obj = self.store.get_item(position)
                if action_obj:
                    self.search.set_text(action_obj.name)
                    self.search.set_position(-1)
                    GLib.idle_add(self.grab_search_focus)
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

    def on_run_clicked(self, button):
        position = self.selection.get_selected()
        if position != Gtk.INVALID_LIST_POSITION and self.store.get_n_items() > 0:
            self.on_activate(self.view, position)

    def on_activate(self, _list_view, position):
        action = self.store.get_item(position)
        if not action:
            return

        dialog = Adw.MessageDialog(
            transient_for=self.window,
            heading="Confirm System Action",
            body=f"Do you really want to execute this action: {action.name}?",
        )
        dialog.add_response("execute", action.name)
        dialog.add_response("cancel", "Cancel")

        if action.name in ("Shutdown", "Reboot"):
            dialog.set_response_appearance(
                "execute", Adw.ResponseAppearance.DESTRUCTIVE
            )
        else:
            dialog.set_response_appearance("execute", Adw.ResponseAppearance.SUGGESTED)

        def handle_response(_, response_id):
            if response_id == "execute":
                try:
                    subprocess.Popen(action.command)
                    self.quit()
                except Exception as e:
                    print(f"Failed to execute system command context: {e}")

        dialog.connect("response", handle_response)
        dialog.present()


if __name__ == "__main__":
    app = PowerLauncher()
    app.run()
