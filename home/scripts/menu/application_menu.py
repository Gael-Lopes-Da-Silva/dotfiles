#!/usr/bin/env python3

import os

os.environ["GSK_RENDERER"] = "gl"

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
gi.require_version("Gdk", "4.0")

from gi.repository import Adw, Gdk, Gio, GLib, GObject, Gtk


# Inherit from GObject.Object so it can be placed directly into a Gio.ListStore
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
        super().__init__(application_id="launcher.apps")

    def do_activate(self):
        self.apps = load_apps()

        self.window = Adw.ApplicationWindow(
            application=self,
        )
        self.window.set_default_size(700, 500)
        self.window.set_decorated(False)
        self.window.set_resizable(False)

        # Main container
        main_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=12,
            margin_top=12,
            margin_bottom=12,
            margin_start=12,
            margin_end=12,
        )

        self.search = Gtk.SearchEntry()
        # Capture key events from the window, allowing "type to search" anywhere
        self.search.set_key_capture_widget(self.window)
        self.search.connect("search-changed", self.on_search)
        self.search.connect("activate", self.on_search_activate)

        main_box.append(self.search)

        # Use our custom App class as the item type
        self.store = Gio.ListStore(item_type=App)
        for app in self.apps:
            self.store.append(app)

        self.selection = Gtk.SingleSelection(model=self.store)

        factory = Gtk.SignalListItemFactory()

        def setup(_, item):
            # Create a horizontal box to hold the icon and the label
            box = Gtk.Box(
                orientation=Gtk.Orientation.HORIZONTAL,
                spacing=12,
                margin_top=10,
                margin_bottom=10,
                margin_start=12,
                margin_end=12,
            )

            icon = Gtk.Image()
            icon.set_pixel_size(32)  # Set a uniform size for all icons

            label = Gtk.Label(xalign=0)

            box.append(icon)
            box.append(label)

            item.set_child(box)

        def bind(_, item):
            app_obj = item.get_item()
            box = item.get_child()

            icon = box.get_first_child()
            label = box.get_last_child()

            # Retrieve the icon from the Gio.AppInfo
            gicon = app_obj.app_info.get_icon()
            if gicon:
                icon.set_from_gicon(gicon)
            else:
                # Fallback icon if the app doesn't have one
                icon.set_from_icon_name("application-x-executable")

            label.set_text(app_obj.name)

        factory.connect("setup", setup)
        factory.connect("bind", bind)

        self.view = Gtk.ListView(
            model=self.selection,
            factory=factory,
            single_click_activate=True,
        )

        self.view.connect("activate", self.on_activate)
        self.view.add_css_class("navigation-sidebar")

        scrolled = Gtk.ScrolledWindow()
        scrolled.set_child(self.view)
        scrolled.set_vexpand(True)

        main_box.append(scrolled)

        # --- Bottom layout for the Run button ---
        bottom_box = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            halign=Gtk.Align.END,  # Align to the right
        )

        self.run_button = Gtk.Button(label="Run")
        self.run_button.add_css_class("suggested-action")
        self.run_button.connect("clicked", self.on_run_clicked)

        bottom_box.append(self.run_button)
        main_box.append(bottom_box)

        self.window.set_content(main_box)
        self.window.present()

        self.search.grab_focus()

    def on_search(self, entry):
        text = entry.get_text().lower()

        self.store.remove_all()

        for app in self.apps:
            if text in app.name.lower():
                self.store.append(app)

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


app = Launcher()
app.run()
