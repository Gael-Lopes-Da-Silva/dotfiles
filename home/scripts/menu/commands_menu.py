#!/usr/bin/env python3

import os
import subprocess

os.environ["GSK_RENDERER"] = "gl"

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
gi.require_version("Gdk", "4.0")

from gi.repository import Adw, Gdk, Gio, GLib, GObject, Gtk


class CommandItem(GObject.Object):
    def __init__(self, name):
        super().__init__()
        self.name = name


class CommandMenu(Adw.Application):
    def __init__(self):
        super().__init__(application_id="launcher.commands")
        self.window = None

    def do_activate(self):
        if self.window:
            self.window.present()
            self.search.grab_focus()
            return

        self.commands = self.load_commands()

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

        search_key_controller = Gtk.EventControllerKey()
        search_key_controller.connect("key-pressed", self.on_key_pressed)
        self.search.add_controller(search_key_controller)

        header.set_title_widget(self.search)
        main_box.append(header)

        self.store = Gio.ListStore(item_type=CommandItem)
        for cmd in self.commands:
            self.store.append(cmd)

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
                margin_top=8,
                margin_bottom=8,
                margin_start=12,
                margin_end=12,
            )

            icon = Gtk.Image.new_from_icon_name("utilities-terminal")
            icon.set_pixel_size(24)

            label = Gtk.Label(xalign=0)

            box.append(icon)
            box.append(label)
            item.set_child(box)

            gesture = Gtk.GestureClick()
            gesture.connect("released", on_row_clicked, item)
            box.add_controller(gesture)

        def bind(_, item):
            cmd_obj = item.get_item()
            box = item.get_child()
            label = box.get_last_child()
            label.set_text(cmd_obj.name)

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

        man_button = Gtk.Button(label="Man Page")
        man_button.connect("clicked", self.on_man_clicked)

        run_button = Gtk.Button(label="Run")
        run_button.add_css_class("suggested-action")
        run_button.connect("clicked", self.on_run_clicked)

        spacer = Gtk.Box(hexpand=True)

        footer_box.append(man_button)
        footer_box.append(spacer)
        footer_box.append(run_button)
        main_box.append(footer_box)

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
                cmd_obj = self.store.get_item(position)
                if cmd_obj:
                    self.search.set_text(cmd_obj.name)
                    self.search.set_position(-1)
                    GLib.idle_add(self.grab_search_focus)
            return True

        return False

    def on_search(self, entry):
        text = entry.get_text().lower()
        self.store.remove_all()
        for cmd in self.commands:
            if text in cmd.name.lower():
                self.store.append(cmd)

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

    def on_man_clicked(self, button):
        position = self.selection.get_selected()
        if position == Gtk.INVALID_LIST_POSITION or self.store.get_n_items() == 0:
            return

        cmd_obj = self.store.get_item(position)
        if not cmd_obj:
            return

        terminal = os.environ.get("TERMINAL")
        man_cmd = f"man '{cmd_obj.name}'"

        if terminal:
            subprocess.Popen(
                [terminal, "--title=Manual Page", "--", "bash", "-c", man_cmd]
            )
        else:
            for term in [
                "xdg-terminal-exec",
                "gnome-terminal",
                "kitty",
                "alacritty",
                "foot",
            ]:
                if GLib.find_program_in_path(term):
                    if term in ["gnome-terminal"]:
                        subprocess.Popen([term, "--", "bash", "-c", man_cmd])
                    else:
                        subprocess.Popen([term, "-e", "bash", "-c", man_cmd])
                    break

        GLib.timeout_add(100, self.quit_app)

    def on_activate(self, _list_view, position):
        cmd_obj = self.store.get_item(position)
        if not cmd_obj:
            return

        subprocess.Popen(
            ["bash", "-c", cmd_obj.name],
            start_new_session=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

        GLib.timeout_add(100, self.quit_app)

    def load_commands(self):
        try:
            result = subprocess.run(
                ["bash", "-c", "compgen -c"], capture_output=True, text=True, check=True
            )
            unique_cmds = sorted(list(set(result.stdout.splitlines())), key=str.lower)

            return [
                CommandItem(cmd)
                for cmd in unique_cmds
                if cmd and not cmd.startswith(".")
            ]
        except Exception:
            return []

    def quit_app(self):
        self.quit()
        return GLib.SOURCE_REMOVE


if __name__ == "__main__":
    app = CommandMenu()
    app.run()
