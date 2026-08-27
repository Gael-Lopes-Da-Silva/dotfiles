#!/usr/bin/env python3

import os
import threading
import time

os.environ["GSK_RENDERER"] = "gl"

import evdev
import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
gi.require_version("Gdk", "4.0")

from evdev import ecodes as e
from gi.repository import Adw, Gdk, GLib, Gtk

KEY_MAP = {
    "a": e.KEY_A,
    "b": e.KEY_B,
    "c": e.KEY_C,
    "d": e.KEY_D,
    "e": e.KEY_E,
    "f": e.KEY_F,
    "g": e.KEY_G,
    "h": e.KEY_H,
    "i": e.KEY_I,
    "j": e.KEY_J,
    "k": e.KEY_K,
    "l": e.KEY_L,
    "m": e.KEY_M,
    "n": e.KEY_N,
    "o": e.KEY_O,
    "p": e.KEY_P,
    "q": e.KEY_Q,
    "r": e.KEY_R,
    "s": e.KEY_S,
    "t": e.KEY_T,
    "u": e.KEY_U,
    "v": e.KEY_V,
    "w": e.KEY_W,
    "x": e.KEY_X,
    "y": e.KEY_Y,
    "z": e.KEY_Z,
    "1": e.KEY_1,
    "2": e.KEY_2,
    "3": e.KEY_3,
    "4": e.KEY_4,
    "5": e.KEY_5,
    "6": e.KEY_6,
    "7": e.KEY_7,
    "8": e.KEY_8,
    "9": e.KEY_9,
    "0": e.KEY_0,
    " ": e.KEY_SPACE,
    "-": e.KEY_MINUS,
    "=": e.KEY_EQUAL,
    "[": e.KEY_LEFTBRACE,
    "]": e.KEY_RIGHTBRACE,
    "\\": e.KEY_BACKSLASH,
    ";": e.KEY_SEMICOLON,
    "'": e.KEY_APOSTROPHE,
    "`": e.KEY_GRAVE,
    ",": e.KEY_COMMA,
    ".": e.KEY_DOT,
    "/": e.KEY_SLASH,
}

SHIFT_MAP = {
    "A": e.KEY_A,
    "B": e.KEY_B,
    "C": e.KEY_C,
    "D": e.KEY_D,
    "E": e.KEY_E,
    "F": e.KEY_F,
    "G": e.KEY_G,
    "H": e.KEY_H,
    "I": e.KEY_I,
    "J": e.KEY_J,
    "K": e.KEY_K,
    "L": e.KEY_L,
    "M": e.KEY_M,
    "N": e.KEY_N,
    "O": e.KEY_O,
    "P": e.KEY_P,
    "Q": e.KEY_Q,
    "R": e.KEY_R,
    "S": e.KEY_S,
    "T": e.KEY_T,
    "U": e.KEY_U,
    "V": e.KEY_V,
    "W": e.KEY_W,
    "X": e.KEY_X,
    "Y": e.KEY_Y,
    "Z": e.KEY_Z,
    "!": e.KEY_1,
    "@": e.KEY_2,
    "#": e.KEY_3,
    "$": e.KEY_4,
    "%": e.KEY_5,
    "^": e.KEY_6,
    "&": e.KEY_7,
    "*": e.KEY_8,
    "(": e.KEY_9,
    ")": e.KEY_0,
    "_": e.KEY_MINUS,
    "+": e.KEY_EQUAL,
    "{": e.KEY_LEFTBRACE,
    "}": e.KEY_RIGHTBRACE,
    "|": e.KEY_BACKSLASH,
    ":": e.KEY_SEMICOLON,
    '"': e.KEY_APOSTROPHE,
    "~": e.KEY_GRAVE,
    "<": e.KEY_COMMA,
    ">": e.KEY_DOT,
    "?": e.KEY_SLASH,
}


class MacrosMenu(Adw.Application):
    def __init__(self):
        super().__init__(application_id="launcher.macros")
        self.is_running = False
        self.automation_thread = None
        self.window = None
        self.ui = None

        self.special_keys_map = [
            ("Return (Enter)", e.KEY_ENTER),
            ("Tab", e.KEY_TAB),
            ("Space", e.KEY_SPACE),
            ("Backspace", e.KEY_BACKSPACE),
            ("Escape", e.KEY_ESC),
            ("Arrow Up", e.KEY_UP),
            ("Arrow Down", e.KEY_DOWN),
            ("Arrow Left", e.KEY_LEFT),
            ("Arrow Right", e.KEY_RIGHT),
            ("Home", e.KEY_HOME),
            ("End", e.KEY_END),
            ("Page Up", e.KEY_PAGEUP),
            ("Page Down", e.KEY_PAGEDOWN),
            ("Insert", e.KEY_INSERT),
            ("Delete", e.KEY_DELETE),
            ("F1", e.KEY_F1),
            ("F2", e.KEY_F2),
            ("F3", e.KEY_F3),
            ("F4", e.KEY_F4),
            ("F5", e.KEY_F5),
            ("F6", e.KEY_F6),
            ("F7", e.KEY_F7),
            ("F8", e.KEY_F8),
            ("F9", e.KEY_F9),
            ("F10", e.KEY_F10),
            ("F11", e.KEY_F11),
            ("F12", e.KEY_F12),
        ]

        self.connect("shutdown", self.on_app_shutdown)

        threading.Thread(target=self.init_virtual_device, daemon=True).start()

    def do_activate(self):
        if self.window:
            self.window.present()
            return

        self.window = Adw.ApplicationWindow(application=self)
        self.window.set_default_size(600, 420)
        self.window.set_decorated(False)
        self.window.set_resizable(False)

        key_controller = Gtk.EventControllerKey()
        key_controller.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
        key_controller.connect("key-pressed", self.on_key_pressed)
        self.window.add_controller(key_controller)

        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)

        header = Adw.HeaderBar()
        header.set_show_title(False)
        header.add_css_class("flat")

        self.delay_dropdown = Gtk.DropDown.new_from_strings(
            ["0 seconds", "1 second", "3 seconds", "5 seconds"]
        )
        header.pack_start(self.delay_dropdown)

        interval_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        interval_box.append(Gtk.Label(label="Interval:"))
        self.interval_spin = Gtk.SpinButton.new_with_range(0, 10000, 10)
        self.interval_spin.set_value(100)
        interval_box.append(self.interval_spin)
        interval_box.append(Gtk.Label(label="ms"))
        header.pack_start(interval_box)

        btn_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)

        self.start_btn = Gtk.Button()
        self.start_btn.set_icon_name("media-playback-start-symbolic")
        self.start_btn.set_tooltip_text("Start (F5)")
        self.start_btn.set_sensitive(False)
        self.start_btn.add_css_class("suggested-action")
        self.start_btn.set_valign(Gtk.Align.CENTER)
        self.start_btn.connect("clicked", self.on_start_clicked)

        self.stop_btn = Gtk.Button()
        self.stop_btn.set_icon_name("media-playback-stop-symbolic")
        self.stop_btn.set_tooltip_text("Stop (F6)")
        self.stop_btn.add_css_class("destructive-action")
        self.stop_btn.set_valign(Gtk.Align.CENTER)
        self.stop_btn.set_sensitive(False)
        self.stop_btn.connect("clicked", self.on_stop_clicked)

        btn_box.append(self.start_btn)
        btn_box.append(self.stop_btn)
        header.pack_end(btn_box)

        main_box.append(header)

        self.stack = Adw.ViewStack()
        self.stack.set_vexpand(True)

        switcher = Adw.ViewSwitcher(stack=self.stack)
        switcher.set_halign(Gtk.Align.CENTER)
        switcher.set_margin_top(15)
        switcher.set_margin_bottom(15)
        main_box.append(switcher)

        mouse_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=15)
        mouse_box.set_halign(Gtk.Align.CENTER)
        mouse_box.set_valign(Gtk.Align.CENTER)
        self.mouse_btn_select = Gtk.DropDown.new_from_strings(
            ["Left", "Middle", "Right"]
        )
        mouse_box.append(Gtk.Label(label="Select Mouse Button:"))
        mouse_box.append(self.mouse_btn_select)

        mouse_page = self.stack.add_titled(mouse_box, "mouse", "Mouse")
        mouse_page.set_icon_name("input-mouse-symbolic")

        kb_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=15)
        kb_box.set_halign(Gtk.Align.CENTER)
        kb_box.set_valign(Gtk.Align.CENTER)

        mode_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        mode_box.append(Gtk.Label(label="Action:"))
        self.kb_action_select = Gtk.DropDown.new_from_strings(
            ["Type Text", "Press Special Key"]
        )
        self.kb_action_select.connect("notify::selected", self.on_kb_action_changed)
        mode_box.append(self.kb_action_select)
        kb_box.append(mode_box)

        self.kb_stack = Gtk.Stack()

        text_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        text_box.append(Gtk.Label(label="Text:"))
        self.key_entry = Gtk.Entry(placeholder_text="e.g., Hello World")
        self.key_entry.set_width_chars(20)
        text_box.append(self.key_entry)
        self.kb_stack.add_named(text_box, "text")

        special_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        special_box.append(Gtk.Label(label="Key:"))

        friendly_names = [item[0] for item in self.special_keys_map]
        self.special_key_select = Gtk.DropDown.new_from_strings(friendly_names)
        special_box.append(self.special_key_select)
        self.kb_stack.add_named(special_box, "special")

        kb_box.append(self.kb_stack)

        mod_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=15)
        self.shift = Gtk.CheckButton(label="Shift")
        self.ctrl = Gtk.CheckButton(label="Ctrl")
        self.alt = Gtk.CheckButton(label="Alt")
        self.super_key = Gtk.CheckButton(label="Super")

        mod_box.append(self.shift)
        mod_box.append(self.ctrl)
        mod_box.append(self.alt)
        mod_box.append(self.super_key)
        kb_box.append(mod_box)

        kb_page = self.stack.add_titled(kb_box, "kb", "Keyboard")
        kb_page.set_icon_name("input-keyboard-symbolic")

        main_box.append(self.stack)

        duration_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        duration_box.set_halign(Gtk.Align.CENTER)
        duration_box.set_margin_bottom(20)
        self.dur_mins = Gtk.SpinButton.new_with_range(0, 60, 1)
        self.dur_secs = Gtk.SpinButton.new_with_range(0, 59, 1)
        self.dur_secs.set_value(5)

        duration_box.append(Gtk.Label(label="Duration of automation:"))
        duration_box.append(self.dur_mins)
        duration_box.append(Gtk.Label(label="mins"))
        duration_box.append(self.dur_secs)
        duration_box.append(Gtk.Label(label="secs"))
        main_box.append(duration_box)

        if self.ui:
            self.start_btn.set_sensitive(True)

        self.window.set_content(main_box)
        self.window.present()

    def on_kb_action_changed(self, dropdown, pspec):
        if dropdown.get_selected() == 0:
            self.kb_stack.set_visible_child_name("text")
        else:
            self.kb_stack.set_visible_child_name("special")

    def on_key_pressed(self, controller, keyval, keycode, state):
        if keyval == Gdk.KEY_Escape:
            self.quit_app()
            return True

        elif keyval == Gdk.KEY_F5:
            if not self.is_running and self.start_btn.get_sensitive():
                self.on_start_clicked(self.start_btn)
            return True

        elif keyval == Gdk.KEY_F6:
            if self.is_running and self.stop_btn.get_sensitive():
                self.on_stop_clicked(self.stop_btn)
            return True

        return False

    def on_start_clicked(self, btn):
        if not self.is_running:
            self.start_btn.set_sensitive(False)
            self.stop_btn.set_sensitive(True)
            self.start_automation()

    def on_stop_clicked(self, btn):
        if self.is_running:
            self.stop_btn.set_sensitive(False)
            self.start_btn.set_sensitive(True)
            self.stop_automation()

    def on_app_shutdown(self, app):
        if self.ui:
            self.ui.close()
            self.ui = None

    def start_automation(self):
        self.is_running = True

        mode = self.stack.get_visible_child_name()
        start_delay = int(
            self.delay_dropdown.get_selected_item().get_string().split()[0]
        )
        interval = self.interval_spin.get_value() / 1000.0
        duration = (self.dur_mins.get_value() * 60) + self.dur_secs.get_value()

        mouse_btn_str = self.mouse_btn_select.get_selected_item().get_string().lower()

        selected_idx = self.special_key_select.get_selected()
        special_keysym = self.special_keys_map[selected_idx][1]

        kb_info = {
            "action_type": self.kb_action_select.get_selected(),
            "text": self.key_entry.get_text(),
            "keysym": special_keysym,
            "shift": self.shift.get_active(),
            "ctrl": self.ctrl.get_active(),
            "alt": self.alt.get_active(),
            "super": self.super_key.get_active(),
        }

        threading.Thread(
            target=self.run_logic,
            args=(mode, start_delay, interval, duration, mouse_btn_str, kb_info),
            daemon=True,
        ).start()

    def stop_automation(self):
        self.is_running = False

    def run_logic(self, mode, start_delay, interval, duration, mouse_btn_str, kb_info):
        time.sleep(start_delay)
        end_time = time.time() + duration if duration > 0 else float("inf")

        if not self.ui:
            GLib.idle_add(self.reset_ui)
            return

        mod_map_keys = []
        if kb_info["shift"]:
            mod_map_keys.append(e.KEY_LEFTSHIFT)
        if kb_info["ctrl"]:
            mod_map_keys.append(e.KEY_LEFTCTRL)
        if kb_info["alt"]:
            mod_map_keys.append(e.KEY_LEFTALT)
        if kb_info["super"]:
            mod_map_keys.append(e.KEY_LEFTMETA)

        mouse_btn_code = e.BTN_LEFT
        if mouse_btn_str == "middle":
            mouse_btn_code = e.BTN_MIDDLE
        elif mouse_btn_str == "right":
            mouse_btn_code = e.BTN_RIGHT

        while self.is_running and time.time() < end_time:
            if mode == "mouse":
                self.ui.write(e.EV_KEY, mouse_btn_code, 1)
                self.ui.syn()
                self.ui.write(e.EV_KEY, mouse_btn_code, 0)
                self.ui.syn()

            elif mode == "kb":
                for mod in mod_map_keys:
                    self.ui.write(e.EV_KEY, mod, 1)
                if mod_map_keys:
                    self.ui.syn()

                if kb_info["action_type"] == 0:
                    text = kb_info["text"]
                    if text:
                        for char in text:
                            shift_needed = False
                            code = None

                            if char in KEY_MAP:
                                code = KEY_MAP[char]
                            elif char in SHIFT_MAP:
                                code = SHIFT_MAP[char]
                                shift_needed = True

                            if code:
                                if shift_needed:
                                    self.ui.write(e.EV_KEY, e.KEY_LEFTSHIFT, 1)
                                    self.ui.syn()

                                self.ui.write(e.EV_KEY, code, 1)
                                self.ui.syn()
                                self.ui.write(e.EV_KEY, code, 0)
                                self.ui.syn()

                                if shift_needed:
                                    self.ui.write(e.EV_KEY, e.KEY_LEFTSHIFT, 0)
                                    self.ui.syn()
                else:
                    code = kb_info["keysym"]
                    self.ui.write(e.EV_KEY, code, 1)
                    self.ui.syn()
                    self.ui.write(e.EV_KEY, code, 0)
                    self.ui.syn()

                for mod in reversed(mod_map_keys):
                    self.ui.write(e.EV_KEY, mod, 0)
                if mod_map_keys:
                    self.ui.syn()

            time.sleep(interval if interval > 0 else 0.001)

        GLib.idle_add(self.reset_ui)

    def init_virtual_device(self):
        cap = {
            e.EV_KEY: [
                e.KEY_ENTER,
                e.KEY_TAB,
                e.KEY_SPACE,
                e.KEY_BACKSPACE,
                e.KEY_ESC,
                e.KEY_UP,
                e.KEY_DOWN,
                e.KEY_LEFT,
                e.KEY_RIGHT,
                e.KEY_HOME,
                e.KEY_END,
                e.KEY_PAGEUP,
                e.KEY_PAGEDOWN,
                e.KEY_INSERT,
                e.KEY_DELETE,
                e.KEY_F1,
                e.KEY_F2,
                e.KEY_F3,
                e.KEY_F4,
                e.KEY_F5,
                e.KEY_F6,
                e.KEY_F7,
                e.KEY_F8,
                e.KEY_F9,
                e.KEY_F10,
                e.KEY_F11,
                e.KEY_F12,
                e.KEY_LEFTSHIFT,
                e.KEY_LEFTCTRL,
                e.KEY_LEFTALT,
                e.KEY_LEFTMETA,
                e.BTN_LEFT,
                e.BTN_RIGHT,
                e.BTN_MIDDLE,
            ]
            + list(range(1, 120))
        }

        try:
            new_ui = evdev.UInput(cap, name="macros-menu-virtual")
            GLib.idle_add(self.set_ui_device, new_ui)
        except Exception as err:
            print(f"\n[ERROR] Failed to create virtual device.")
            print(f"Ensure you have write permissions to /dev/uinput: {err}")
            print(
                f"Adding user to 'input' group handles /dev/input, but /dev/uinput might need a udev rule.\n"
            )
            GLib.idle_add(self.reset_ui)

    def set_ui_device(self, ui_device):
        self.ui = ui_device
        if self.window and hasattr(self, "start_btn"):
            self.start_btn.set_sensitive(True)
        return False

    def reset_ui(self):
        self.start_btn.set_sensitive(True)
        self.stop_btn.set_sensitive(False)
        self.is_running = False
        return False

    def quit_app(self):
        self.quit()
        return GLib.SOURCE_REMOVE


if __name__ == "__main__":
    app = MacrosMenu()
    app.run()
