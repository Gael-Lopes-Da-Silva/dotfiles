#!/usr/bin/env python3

import os
import re
import subprocess
from pathlib import Path

os.environ["GSK_RENDERER"] = "gl"

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
gi.require_version("Gdk", "4.0")

from gi.repository import Adw, Gdk, Gio, GLib, GObject, Gtk, Pango


class SoundItem(GObject.Object):
    def __init__(self, display_name, file_path):
        super().__init__()
        self.display_name = display_name
        self.file_path = file_path


def load_sound_items():
    soundboard_dir = Path.home() / ".soundboard"
    # Ensure directories exist seamlessly on startup
    soundboard_dir.mkdir(parents=True, exist_ok=True)
    (soundboard_dir / "custom").mkdir(parents=True, exist_ok=True)

    extensions = {
        ".mp3",
        ".aac",
        ".wav",
        ".flac",
        ".ogg",
        ".opus",
        ".aiff",
        ".au",
        ".caf",
        ".raw",
    }
    items = []

    try:
        # Scan only the top-level folder for standard audio extensions
        for path in soundboard_dir.iterdir():
            if path.is_file() and path.suffix.lower() in extensions:
                # Replicate bash formatting: change separators to spaces and capitalize
                name_attr = path.stem.replace("-", " ").replace("_", " ")
                display_name = name_attr.strip().capitalize()
                items.append(SoundItem(display_name, str(path)))

        # Keep everything organized cleanly from A to Z
        items.sort(key=lambda x: x.display_name.lower())
    except Exception as e:
        print(f"Error indexing sound bank paths: {e}")

    return items


class SoundboardLauncher(Adw.Application):
    def __init__(self):
        super().__init__(application_id="launcher.soundboard")
        self.recording_process = None
        self.rec_filename = Path.home() / ".soundboard" / "custom" / "record.wav"

    def do_activate(self):
        self.all_items = load_sound_items()

        self.window = Adw.ApplicationWindow(application=self)
        self.window.set_default_size(700, 520)
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

        # Hook key event processing controllers
        key_controller = Gtk.EventControllerKey()
        key_controller.connect("key-pressed", self.on_key_pressed)
        self.window.add_controller(key_controller)

        search_key_controller = Gtk.EventControllerKey()
        search_key_controller.connect("key-pressed", self.on_key_pressed)
        self.search.add_controller(search_key_controller)

        main_box.append(self.search)

        # Data-Binding UI Store Layout
        self.store = Gio.ListStore(item_type=SoundItem)
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
            icon = Gtk.Image.new_from_icon_name("audio-x-generic-symbolic")
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
            label.set_text(item_obj.display_name)

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

        # Action shortcuts quick-reference guide
        footer_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        help_label = Gtk.Label(xalign=0)
        help_label.set_markup(
            "<span size='small' foreground='#888888'>"
            "<b>Enter</b> Play | <b>Tab</b> Complete | <b>Ctrl+R</b> Record Toggle | "
            "<b>Ctrl+S</b> Save Rec | <b>Ctrl+F</b> Play Rec\n"
            "<b>Ctrl+C</b> Stop All Sounds | <b>Ctrl+G</b> Rename | "
            "<b>Ctrl+D</b> Delete File"
            "</span>"
        )
        footer_box.append(help_label)
        main_box.append(footer_box)

        self.window.set_content(main_box)
        self.window.present()
        self.search.grab_focus()

    def reload_store_view(self):
        text = self.search.get_text().lower()
        self.store.remove_all()
        for item in self.all_items:
            if text in item.display_name.lower():
                self.store.append(item)

    def on_key_pressed(self, controller, keyval, keycode, state):
        if keyval == Gdk.KEY_Escape:
            # If the application is actively recording, close out the process safely first
            if self.recording_process:
                self.action_toggle_recording()
            else:
                self.quit()
            return True

        if keyval in (Gdk.KEY_Tab, Gdk.KEY_ISO_Left_Tab):
            position = self.selection.get_selected()
            if position != Gtk.INVALID_LIST_POSITION and self.store.get_n_items() > 0:
                item_obj = self.store.get_item(position)
                if item_obj:
                    self.search.set_text(item_obj.display_name)
                    self.search.set_position(-1)
                    GLib.idle_add(self.grab_search_focus)
            return True

        is_ctrl = (state & Gdk.ModifierType.CONTROL_MASK) != 0
        if is_ctrl:
            if keyval == Gdk.KEY_c:
                self.action_stop_all()
                return True
            elif keyval == Gdk.KEY_r:
                self.action_toggle_recording()
                return True
            elif keyval == Gdk.KEY_f:
                self.action_play_last_recording()
                return True
            elif keyval == Gdk.KEY_s:
                self.action_save_recording()
                return True
            elif keyval == Gdk.KEY_g:
                self.action_rename_selected()
                return True
            elif keyval == Gdk.KEY_d:
                self.action_delete_selected()
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
        if item:
            self.play_audio_file(item.file_path)

    def play_audio_file(self, path_str):
        # Dispatches dual sink delivery targeting virtual loopback + default pipelines concurrently
        cmd = f"paplay --device='SoundboardSink' --volume=65536 '{path_str}' & paplay --device='$(pactl get-default-sink)' --volume=32768 '{path_str}' &"
        subprocess.Popen(cmd, shell=True, preexec_fn=os.setsid)

    # --- Action Implementations ---

    def action_stop_all(self):
        subprocess.run(["pkill", "paplay"])
        self.send_notification(
            "Soundboard", "All background audio channels terminated."
        )

    def action_toggle_recording(self):
        if self.recording_process is None:
            # Replicates: pw-record balance channels tracking loops
            try:
                self.recording_process = subprocess.Popen(
                    ["pw-record", str(self.rec_filename)],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                self.send_notification(
                    "Soundboard",
                    "Microphone loop active... Press Ctrl+R or ESC to stop.",
                )
            except Exception as e:
                print(f"Failed to start pw-record pipeline wrapper: {e}")
        else:
            # Terminate and clean up cleanly
            if self.recording_process.poll() is None:
                self.recording_process.terminate()
                self.recording_process.wait()
            self.recording_process = None
            self.send_notification(
                "Soundboard", "Microphone capture stored successfully."
            )

    def action_play_last_recording(self):
        if self.rec_filename.exists():
            self.play_audio_file(str(self.rec_filename))
        else:
            self.send_notification("Soundboard", "No recent capture script logs found.")

    def action_save_recording(self):
        if not self.rec_filename.exists():
            self.send_notification("Soundboard", "No voice sample available to cache.")
            return

        dialog = Adw.MessageDialog(
            transient_for=self.window,
            heading="Save Captured Audio",
            body="Enter a clean system tag layout name for this sound entry:",
        )
        entry = Gtk.Entry(placeholder_text="e.g., epic airhorn")
        dialog.set_extra_child(entry)

        dialog.add_response("cancel", "Cancel")
        dialog.add_response("save", "Save Sound")
        dialog.set_response_appearance("save", Adw.ResponseAppearance.SUGGESTED)

        def handle_response(_, response_id):
            name = entry.get_text().strip()
            if response_id == "save" and name:
                # Bash mirror sanitization regex pipelines rules
                safe_name = name.replace(" ", "-")
                safe_name = re.sub(r"[^a-zA-Z0-9_ -]", "", safe_name).lower()

                dest_file = Path.home() / ".soundboard" / f"{safe_name}.wav"
                if dest_file.exists():
                    self.send_notification(
                        "Soundboard",
                        f"Filename mapping clashes: '{safe_name}.wav' already exists.",
                    )
                    return

                try:
                    subprocess.run(
                        ["cp", str(self.rec_filename), str(dest_file)], check=True
                    )
                    self.send_notification(
                        "Soundboard",
                        f"Successfully indexed '{name}' into profile track list.",
                    )
                    self.refresh_data()
                except Exception as e:
                    print(f"Error copying recording: {e}")

        dialog.connect("response", handle_response)
        dialog.present()

    def action_rename_selected(self):
        position = self.selection.get_selected()
        if position == Gtk.INVALID_LIST_POSITION or self.store.get_n_items() == 0:
            return

        item = self.store.get_item(position)
        source_path = Path(item.file_path)

        dialog = Adw.MessageDialog(
            transient_for=self.window,
            heading="Rename Sound Byte",
            body=f"Provide an updated track alias for '{item.display_name}':",
        )
        entry = Gtk.Entry(text=item.display_name)
        dialog.set_extra_child(entry)

        dialog.add_response("cancel", "Cancel")
        dialog.add_response("rename", "Apply Rename")
        dialog.set_response_appearance("rename", Adw.ResponseAppearance.SUGGESTED)

        def handle_response(_, response_id):
            name = entry.get_text().strip()
            if response_id == "rename" and name:
                safe_name = name.replace(" ", "-")
                safe_name = re.sub(r"[^a-zA-Z0-9_ -]", "", safe_name).lower()

                dest_file = source_path.parent / f"{safe_name}{source_path.suffix}"
                try:
                    source_path.rename(dest_file)
                    self.send_notification(
                        "Soundboard", "Audio track modified successfully."
                    )
                    self.refresh_data()
                except Exception as e:
                    print(f"Filesystem mapping migration crash: {e}")

        dialog.connect("response", handle_response)
        dialog.present()

    def action_delete_selected(self):
        position = self.selection.get_selected()
        if position == Gtk.INVALID_LIST_POSITION or self.store.get_n_items() == 0:
            return

        item = self.store.get_item(position)

        dialog = Adw.MessageDialog(
            transient_for=self.window,
            heading="Wipe Audio Sample?",
            body=f"Are you sure you want to completely erase '{item.display_name}'? This cannot be undone.",
        )
        dialog.add_response("cancel", "Cancel")
        dialog.add_response("delete", "Delete Sound")
        dialog.set_response_appearance("delete", Adw.ResponseAppearance.DESTRUCTIVE)

        def handle_response(_, response_id):
            if response_id == "delete":
                try:
                    Path(item.file_path).unlink()
                    self.send_notification(
                        "Soundboard", "Audio track cleared from disk."
                    )
                    self.refresh_data()
                except Exception as e:
                    print(f"Error unlinking entry line: {e}")

        dialog.connect("response", handle_response)
        dialog.present()

    def refresh_data(self):
        self.all_items = load_sound_items()
        self.reload_store_view()
        GLib.idle_add(self.grab_search_focus)

    def send_notification(self, title, message):
        try:
            subprocess.run(
                ["notify-send", "-a", "notification", "-t", "5000", title, message]
            )
        except Exception as e:
            print(f"Notification manager runtime exception: {e}")


if __name__ == "__main__":
    app = SoundboardLauncher()
    app.run()
