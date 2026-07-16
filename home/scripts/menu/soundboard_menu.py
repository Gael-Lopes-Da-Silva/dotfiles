#!/usr/bin/env python3

import os
import re
import signal
import subprocess
from pathlib import Path

os.environ["GSK_RENDERER"] = "gl"

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
gi.require_version("Gdk", "4.0")
gi.require_version("Gio", "2.0")
gi.require_version("Pango", "1.0")

from gi.repository import Adw, Gdk, Gio, GLib, GObject, Gtk, Pango


class SoundboardItem(GObject.Object):
    is_playing = GObject.Property(type=bool, default=False)

    def __init__(self, display_name, file_path):
        super().__init__()
        self.display_name = display_name
        self.file_path = file_path


class SoundboardMenu(Adw.Application):
    def __init__(self):
        super().__init__(application_id="launcher.soundboard")
        self.recording_process = None
        self.recording_popup = None
        self.rec_filename = Path.home() / ".soundboard" / "custom" / "record.wav"
        self.window = None

        self.playing_sounds = {}
        self.overlapping_sounds = {}
        self.signal_handlers = {}

        GLib.timeout_add(250, self.check_playing_sounds)

    def do_activate(self):
        if self.window:
            self.window.present()
            self.search.grab_focus()
            return

        self.all_items = self.load_sound_items()

        self.window = Adw.ApplicationWindow(application=self)
        self.window.set_default_size(780, 520)
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

        key_controller = Gtk.EventControllerKey()
        key_controller.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
        key_controller.connect("key-pressed", self.on_key_pressed)
        self.window.add_controller(key_controller)

        search_key_controller = Gtk.EventControllerKey()
        search_key_controller.connect("key-pressed", self.on_key_pressed)
        self.search.add_controller(search_key_controller)

        header.set_title_widget(self.search)
        main_box.append(header)

        self.store = Gio.ListStore(item_type=SoundboardItem)
        self.selection = Gtk.SingleSelection(model=self.store)
        self.reload_store_view()

        factory = Gtk.SignalListItemFactory()

        def on_row_clicked(gesture, n_press, x, y, item):
            if n_press == 1:
                position = item.get_position()
                if position != Gtk.INVALID_LIST_POSITION:
                    self.selection.set_selected(position)

        def setup(_, item):
            box = Gtk.Box(
                orientation=Gtk.Orientation.HORIZONTAL,
                spacing=12,
                margin_top=6,
                margin_bottom=6,
                margin_start=12,
                margin_end=12,
            )
            icon = Gtk.Image.new_from_icon_name("audio-x-generic-symbolic")
            label = Gtk.Label(xalign=0)
            label.set_ellipsize(Pango.EllipsizeMode.END)
            label.set_hexpand(True)

            spinner = Gtk.Spinner()
            spinner.set_visible(False)

            box.append(icon)
            box.append(label)
            box.append(spinner)

            btn_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)

            btn_toggle = Gtk.Button.new_from_icon_name("media-playback-start-symbolic")
            btn_toggle.connect("clicked", lambda _: self.toggle_row_item(item))

            btn_overlap_play = Gtk.Button.new_from_icon_name(
                "media-playlist-repeat-symbolic"
            )
            btn_overlap_play.set_tooltip_text("Play Overlapping")
            btn_overlap_play.connect(
                "clicked", lambda _: self.play_overlap_row_item(item)
            )

            btn_rename = Gtk.Button.new_from_icon_name("document-edit-symbolic")
            btn_rename.set_tooltip_text("Rename Sound")
            btn_rename.connect("clicked", lambda _: self.rename_row_item(item))

            btn_delete = Gtk.Button.new_from_icon_name("user-trash-symbolic")
            btn_delete.set_tooltip_text("Delete Sound")
            btn_delete.add_css_class("destructive-action")
            btn_delete.connect("clicked", lambda _: self.delete_row_item(item))

            btn_box.append(btn_toggle)
            btn_box.append(btn_overlap_play)
            btn_box.append(btn_rename)
            btn_box.append(btn_delete)

            box.append(btn_box)
            item.set_child(box)

            gesture = Gtk.GestureClick()
            gesture.connect("released", on_row_clicked, item)
            box.add_controller(gesture)

        def bind(_, item):
            item_obj = item.get_item()
            if not item_obj:
                return

            box = item.get_child()
            icon = box.get_first_child()
            label = icon.get_next_sibling()
            spinner = label.get_next_sibling()
            btn_box = spinner.get_next_sibling()
            btn_toggle = btn_box.get_first_child()

            label.set_text(item_obj.display_name)

            def update_playback_ui(*args):
                if item_obj.get_property("is_playing"):
                    spinner.set_visible(True)
                    spinner.start()
                    btn_toggle.set_icon_name("media-playback-stop-symbolic")
                    btn_toggle.set_tooltip_text("Stop Sound")
                else:
                    spinner.stop()
                    spinner.set_visible(False)
                    btn_toggle.set_icon_name("media-playback-start-symbolic")
                    btn_toggle.set_tooltip_text("Play Sound")

            update_playback_ui()
            handler_id = item_obj.connect("notify::is-playing", update_playback_ui)
            self.signal_handlers[item] = (item_obj, handler_id)

        def unbind(_, item):
            if item in self.signal_handlers:
                item_obj, handler_id = self.signal_handlers.pop(item)
                try:
                    item_obj.disconnect(handler_id)
                except:
                    pass

        factory.connect("setup", setup)
        factory.connect("bind", bind)
        factory.connect("unbind", unbind)

        self.view = Gtk.ListView(
            model=self.selection,
            factory=factory,
            single_click_activate=False,
        )
        self.view.add_css_class("navigation-sidebar")

        scrolled = Gtk.ScrolledWindow()
        scrolled.set_child(self.view)
        scrolled.set_vexpand(True)
        main_box.append(scrolled)

        footer_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)

        btn_stop_all = Gtk.Button(label="Stop All Sounds")
        btn_stop_all.add_css_class("destructive-action")
        btn_stop_all.connect("clicked", lambda _: self.action_stop_all())
        footer_box.append(btn_stop_all)

        btn_record = Gtk.Button(label="Record")
        btn_record.connect("clicked", lambda _: self.action_start_recording())
        footer_box.append(btn_record)

        btn_save_rec = Gtk.Button(label="Save Record")
        btn_save_rec.connect("clicked", lambda _: self.action_save_recording())
        footer_box.append(btn_save_rec)

        btn_play_rec = Gtk.Button(label="Play Record")
        btn_play_rec.connect("clicked", lambda _: self.action_play_last_recording())
        footer_box.append(btn_play_rec)

        spacer = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        spacer.set_hexpand(True)
        footer_box.append(spacer)

        btn_play_focused = Gtk.Button(label="Play Focused")
        btn_play_focused.add_css_class("suggested-action")
        btn_play_focused.connect("clicked", lambda _: self.action_play_focused())
        footer_box.append(btn_play_focused)

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
            self.quit()
            return True

        if keyval in (Gdk.KEY_Return, Gdk.KEY_KP_Enter):
            if not self.search.has_focus():
                self.play_currently_selected()
                return True

        if keyval in (Gdk.KEY_Tab, Gdk.KEY_ISO_Left_Tab):
            position = self.selection.get_selected()
            if position != Gtk.INVALID_LIST_POSITION and self.store.get_n_items() > 0:
                action_obj = self.store.get_item(position)
                if action_obj:
                    self.search.set_text(action_obj.display_name)
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

    def play_currently_selected(self):
        if self.store.get_n_items() > 0:
            position = self.selection.get_selected()
            if (
                position == Gtk.INVALID_LIST_POSITION
                or position >= self.store.get_n_items()
            ):
                position = 0

            item = self.store.get_item(position)
            if item:
                self.play_audio_file(item)

    def update_item_playing_state(self, item_obj):
        path_str = item_obj.file_path
        has_exclusive = path_str in self.playing_sounds
        has_overlapping = (
            path_str in self.overlapping_sounds
            and len(self.overlapping_sounds[path_str]) > 0
        )
        item_obj.set_property("is_playing", has_exclusive or has_overlapping)

    def check_playing_sounds(self):
        finished_exclusive = []
        for path_str, (proc, item_obj) in list(self.playing_sounds.items()):
            if proc.poll() is not None:
                finished_exclusive.append(path_str)

        for path_str in finished_exclusive:
            if path_str in self.playing_sounds:
                _, item_obj = self.playing_sounds.pop(path_str)
                self.update_item_playing_state(item_obj)

        for item_obj in self.all_items:
            path_str = item_obj.file_path
            if path_str in self.overlapping_sounds:
                active_procs = [
                    p for p in self.overlapping_sounds[path_str] if p.poll() is None
                ]
                if len(active_procs) != len(self.overlapping_sounds[path_str]):
                    if active_procs:
                        self.overlapping_sounds[path_str] = active_procs
                    else:
                        self.overlapping_sounds.pop(path_str, None)
                    self.update_item_playing_state(item_obj)
        return True

    def play_audio_file(self, item_obj):
        path_str = item_obj.file_path
        if path_str in self.playing_sounds:
            self.stop_audio_file(item_obj)

        cmd = f"paplay --device='SoundboardSink' --volume=65536 '{path_str}' & paplay --device='$(pactl get-default-sink)' --volume=32768 '{path_str}' & wait"
        try:
            proc = subprocess.Popen(cmd, shell=True, preexec_fn=os.setsid)
            self.playing_sounds[path_str] = (proc, item_obj)
            self.update_item_playing_state(item_obj)
        except Exception as e:
            print(f"Error executing audio command stream: {e}")

    def stop_audio_file(self, item_obj):
        path_str = item_obj.file_path
        if path_str in self.playing_sounds:
            proc, _ = self.playing_sounds[path_str]
            try:
                os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
                proc.wait()
            except:
                pass
            del self.playing_sounds[path_str]
        self.update_item_playing_state(item_obj)

    def play_audio_overlapping(self, item_obj):
        path_str = item_obj.file_path
        cmd = f"paplay --device='SoundboardSink' --volume=65536 '{path_str}' & paplay --device='$(pactl get-default-sink)' --volume=32768 '{path_str}' & wait"
        try:
            proc = subprocess.Popen(cmd, shell=True, preexec_fn=os.setsid)
            if path_str not in self.overlapping_sounds:
                self.overlapping_sounds[path_str] = []
            self.overlapping_sounds[path_str].append(proc)
            self.update_item_playing_state(item_obj)
        except Exception as e:
            print(f"Error executing overlapping audio: {e}")

    def stop_audio_overlapping(self, item_obj):
        path_str = item_obj.file_path
        if path_str in self.overlapping_sounds:
            for proc in self.overlapping_sounds[path_str]:
                try:
                    os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
                    proc.wait()
                except:
                    pass
            del self.overlapping_sounds[path_str]
        self.update_item_playing_state(item_obj)

    def toggle_row_item(self, item):
        item_obj = item.get_item()
        if item_obj:
            if item_obj.get_property("is_playing"):
                self.stop_audio_file(item_obj)
                self.stop_audio_overlapping(item_obj)
            else:
                self.play_audio_file(item_obj)

    def play_overlap_row_item(self, item):
        item_obj = item.get_item()
        if item_obj:
            self.play_audio_overlapping(item_obj)

    def rename_row_item(self, item):
        item_obj = item.get_item()
        if item_obj:
            self.action_rename_selected_item(item_obj)

    def delete_row_item(self, item):
        item_obj = item.get_item()
        if item_obj:
            self.action_delete_selected_item(item_obj)

    def action_play_focused(self):
        position = self.selection.get_selected()
        if position != Gtk.INVALID_LIST_POSITION and self.store.get_n_items() > 0:
            item = self.store.get_item(position)
            if item:
                self.play_audio_file(item)

    def action_stop_all(self):
        for path_str, (proc, item_obj) in self.playing_sounds.items():
            try:
                os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
                proc.wait()
            except:
                pass
        self.playing_sounds.clear()

        for path_str, procs in self.overlapping_sounds.items():
            for proc in procs:
                try:
                    os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
                    proc.wait()
                except:
                    pass
        self.overlapping_sounds.clear()

        for item in self.all_items:
            item.set_property("is_playing", False)

    def action_start_recording(self):
        if self.recording_process is not None:
            return

        try:
            self.recording_process = subprocess.Popen(
                ["pw-record", str(self.rec_filename)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            self.open_recording_popup()
        except Exception as e:
            print(f"Failed to start pw-record pipeline wrapper: {e}")

    def open_recording_popup(self):
        self.recording_popup = Gtk.Window(
            transient_for=self.window,
            modal=True,
            title="Recording Manager",
            destroy_with_parent=True,
        )
        self.recording_popup.set_default_size(260, 130)

        vbox = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=16,
            margin_top=16,
            margin_bottom=16,
            margin_start=16,
            margin_end=16,
        )

        label = Gtk.Label(label="Audio capture active...")
        label.set_halign(Gtk.Align.CENTER)

        btn_stop = Gtk.Button(label="Stop Recording")
        btn_stop.add_css_class("destructive-action")
        btn_stop.set_halign(Gtk.Align.CENTER)
        btn_stop.connect("clicked", lambda _: self.action_stop_recording())

        vbox.append(label)
        vbox.append(btn_stop)
        self.recording_popup.set_child(vbox)

        key_ctrl = Gtk.EventControllerKey()
        key_ctrl.connect("key-pressed", self.on_popup_key_pressed)
        self.recording_popup.add_controller(key_ctrl)

        self.recording_popup.present()

    def on_popup_key_pressed(self, controller, keyval, keycode, state):
        if keyval == Gdk.KEY_Escape:
            self.action_stop_recording()
            return True
        return False

    def action_stop_recording(self):
        if self.recording_process:
            if self.recording_process.poll() is None:
                self.recording_process.terminate()
                self.recording_process.wait()
            self.recording_process = None

        if self.recording_popup:
            self.recording_popup.destroy()
            self.recording_popup = None

    def action_play_last_recording(self):
        if self.rec_filename.exists():
            cmd = f"paplay --device='SoundboardSink' --volume=65536 '{self.rec_filename}' & paplay --device='$(pactl get-default-sink)' --volume=32768 '{self.rec_filename}' &"
            subprocess.Popen(cmd, shell=True, preexec_fn=os.setsid)

    def action_save_recording(self):
        if not self.rec_filename.exists():
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
                safe_name = name.replace(" ", "-")
                safe_name = re.sub(r"[^a-zA-Z0-9_ -]", "", safe_name).lower()

                dest_file = Path.home() / ".soundboard" / f"{safe_name}.wav"
                if dest_file.exists():
                    return

                try:
                    subprocess.run(
                        ["cp", str(self.rec_filename), str(dest_file)], check=True
                    )
                    self.refresh_data()
                except Exception as e:
                    print(f"Error copying recording: {e}")

        dialog.connect("response", handle_response)
        dialog.present()

    def action_rename_selected_item(self, item):
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
                    self.refresh_data()
                except Exception as e:
                    print(f"Filesystem mapping migration crash: {e}")

        dialog.connect("response", handle_response)
        dialog.present()

    def action_delete_selected_item(self, item):
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
                    self.refresh_data()
                except Exception as e:
                    print(f"Error unlinking entry line: {e}")

        dialog.connect("response", handle_response)
        dialog.present()

    def load_sound_items(self):
        soundboard_dir = Path.home() / ".soundboard"
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
            for path in soundboard_dir.iterdir():
                if path.is_file() and path.suffix.lower() in extensions:
                    name_attr = path.stem.replace("-", " ").replace("_", " ")
                    display_name = name_attr.strip().capitalize()
                    items.append(SoundboardItem(display_name, str(path)))

            items.sort(key=lambda x: x.display_name.lower())
        except Exception:
            return []

        return items

    def refresh_data(self):
        self.all_items = self.load_sound_items()
        self.reload_store_view()
        GLib.idle_add(self.grab_search_focus)


if __name__ == "__main__":
    app = SoundboardMenu()
    app.run()
