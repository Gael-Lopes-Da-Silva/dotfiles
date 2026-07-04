#!/usr/bin/env python3

import subprocess
import threading
import time

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")

from gi.repository import Adw, Gdk, GLib, Gtk


class MacrosMenu(Adw.Application):
    def __init__(self):
        super().__init__(application_id="launcher.macros")
        self.is_running = False
        self.automation_thread = None
        self.window = None

        self.special_keys_map = [
            ("Return (Enter)", "Return"),
            ("Tab", "Tab"),
            ("Space", "space"),
            ("Backspace", "BackSpace"),
            ("Escape", "Escape"),
            ("Arrow Up", "Up"),
            ("Arrow Down", "Down"),
            ("Arrow Left", "Left"),
            ("Arrow Right", "Right"),
            ("Home", "Home"),
            ("End", "End"),
            ("Page Up", "Prior"),
            ("Page Down", "Next"),
            ("Insert", "Insert"),
            ("Delete", "Delete"),
            ("F1", "F1"),
            ("F2", "F2"),
            ("F3", "F3"),
            ("F4", "F4"),
            ("F5", "F5"),
            ("F6", "F6"),
            ("F7", "F7"),
            ("F8", "F8"),
            ("F9", "F9"),
            ("F10", "F10"),
            ("F11", "F11"),
            ("F12", "F12"),
        ]

    def do_activate(self):
        if self.window:
            self.window.present()
            return

        self.window = Adw.ApplicationWindow(
            application=self, title="Clicker (wlrctl & wtype)"
        )
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

        self.toggle_btn = Gtk.ToggleButton()
        self.toggle_btn.set_icon_name("media-playback-start-symbolic")
        self.toggle_btn.add_css_class("suggested-action")
        self.toggle_btn.set_valign(Gtk.Align.CENTER)
        self.toggle_btn.connect("toggled", self.on_toggle_clicked)
        header.pack_end(self.toggle_btn)

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

        self.window.set_content(main_box)
        self.window.present()

    def on_kb_action_changed(self, dropdown, pspec):
        if dropdown.get_selected() == 0:
            self.kb_stack.set_visible_child_name("text")
        else:
            self.kb_stack.set_visible_child_name("special")

    def on_key_pressed(self, controller, keyval, keycode, state):
        focused_widget = self.window.get_focus()

        if keyval == Gdk.KEY_Escape:
            self.window.close()
            return True

        elif keyval in (Gdk.KEY_space, Gdk.KEY_Return, Gdk.KEY_KP_Enter):
            if focused_widget and isinstance(focused_widget, (Gtk.Text, Gtk.Editable)):
                return False

            current_state = self.toggle_btn.get_active()
            self.toggle_btn.set_active(not current_state)
            return True

        return False

    def on_toggle_clicked(self, btn):
        if btn.get_active():
            btn.set_icon_name("media-playback-stop-symbolic")
            btn.remove_css_class("suggested-action")
            btn.add_css_class("destructive-action")
            if not self.is_running:
                self.start_automation()
        else:
            btn.set_icon_name("media-playback-start-symbolic")
            btn.remove_css_class("destructive-action")
            btn.add_css_class("suggested-action")
            if self.is_running:
                self.stop_automation()

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

        mod_map = {
            "shift": kb_info["shift"],
            "ctrl": kb_info["ctrl"],
            "alt": kb_info["alt"],
            "logo": kb_info["super"],
        }

        while self.is_running and time.time() < end_time:
            if mode == "mouse":
                subprocess.run(
                    ["wlrctl", "pointer", "click", mouse_btn_str],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
            elif mode == "kb":
                try:
                    cmd = ["wtype"]

                    for mod_name, is_active in mod_map.items():
                        if is_active:
                            cmd.extend(["-M", mod_name])

                    if kb_info["action_type"] == 0:
                        if kb_info["text"]:
                            cmd.append(kb_info["text"])
                        else:
                            time.sleep(interval if interval > 0 else 0.001)
                            continue
                    else:
                        cmd.extend(["-k", kb_info["keysym"]])

                    for mod_name, is_active in mod_map.items():
                        if is_active:
                            cmd.extend(["-m", mod_name])

                    subprocess.run(
                        cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
                    )
                except Exception as e:
                    print(f"wtype execution error: {e}")
                    break

            time.sleep(interval if interval > 0 else 0.001)

        GLib.idle_add(self.reset_ui)

    def reset_ui(self):
        if self.toggle_btn.get_active():
            self.toggle_btn.set_active(False)
        return False


if __name__ == "__main__":
    app = MacrosMenu()
    app.run()
