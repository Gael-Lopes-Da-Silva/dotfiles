#!/usr/bin/env python3

import os

os.environ["GSK_RENDERER"] = "gl"

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
gi.require_version("Gdk", "4.0")

from gi.repository import Adw, Gdk, Gio, GLib, GObject, Gtk


class App(GObject.Object):
    def __init__(self, app_info):
        super().__init__()
        self.name = app_info.get_name()
        self.app_info = app_info


def load_apps():
    apps = {}

    for app_info in Gio.AppInfo.get_all():
        if app_info.should_show():
            name = app_info.get_name()
            if name:
                apps[name] = App(app_info)

    return sorted(apps.values(), key=lambda x: x.name.lower())


class Launcher(Adw.Application):
    def __init__(self):
        super().__init__(application_id="launcher.applications")
        self.window = None

    def do_activate(self):
        if self.window:
            self.window.present()
            self.search.grab_focus()
            return

        self.apps = load_apps()

        self.window = Adw.ApplicationWindow(
            application=self,
        )
        self.window.set_default_size(700, 500)
        self.window.set_decorated(False)
        self.window.set_resizable(False)

        key_controller = Gtk.EventControllerKey()
        key_controller.connect("key-pressed", self.on_key_pressed)
        self.window.add_controller(key_controller)

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

        search_key_controller = Gtk.EventControllerKey()
        search_key_controller.connect("key-pressed", self.on_key_pressed)
        self.search.add_controller(search_key_controller)

        main_box.append(self.search)

        self.store = Gio.ListStore(item_type=App)
        for app in self.apps:
            self.store.append(app)

        self.selection = Gtk.SingleSelection(model=self.store)

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
            icon.set_pixel_size(32)

            label = Gtk.Label(xalign=0)

            box.append(icon)
            box.append(label)

            item.set_child(box)

            gesture = Gtk.GestureClick()
            gesture.connect("released", on_row_clicked, item)
            box.add_controller(gesture)

        def bind(_, item):
            app_obj = item.get_item()
            box = item.get_child()

            icon = box.get_first_child()
            label = box.get_last_child()

            gicon = app_obj.app_info.get_icon()
            if gicon:
                icon.set_from_gicon(gicon)
            else:
                icon.set_from_icon_name("application-x-executable")

            label.set_text(app_obj.name)

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

        bottom_box = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            halign=Gtk.Align.END,
        )

        self.run_button = Gtk.Button(label="Run")
        self.run_button.add_css_class("suggested-action")
        self.run_button.connect("clicked", self.on_run_clicked)

        bottom_box.append(self.run_button)
        main_box.append(bottom_box)

        self.window.set_content(main_box)
        self.window.present()

        self.search.grab_focus()

    def on_key_pressed(self, controller, keyval, keycode, state):
        if keyval == Gdk.KEY_Escape:
            self.quit()
            return True

        if keyval in (Gdk.KEY_Tab, Gdk.KEY_ISO_Left_Tab):
            position = self.selection.get_selected()
            if position != Gtk.INVALID_LIST_POSITION and self.store.get_n_items() > 0:
                app_obj = self.store.get_item(position)
                if app_obj:
                    self.search.set_text(app_obj.name)
                    self.search.set_position(-1)
                    GLib.idle_add(self.grab_search_focus)
            return True

        return False

    def on_search(self, entry):
        text = entry.get_text().lower()

        self.store.remove_all()

        for app in self.apps:
            if text in app.name.lower():
                self.store.append(app)

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
        app = self.store.get_item(position)

        if not app:
            return

        context = Gdk.Display.get_default().get_app_launch_context()
        app.app_info.launch([], context)

        GLib.timeout_add(100, self.quit_app)

    def quit_app(self):
        self.quit()
        return GLib.SOURCE_REMOVE


if __name__ == "__main__":
    app = Launcher()
    app.run()
