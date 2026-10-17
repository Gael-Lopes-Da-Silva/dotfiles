import QtQuick
import Quickshell.Io
import qs.osd
import qs.glance
import qs.notifications
import qs.controls
import qs.launcher

Item {
	IpcHandler {
		target: "osd"

		function raiseVolume() {
			Osd.raiseVolume()
		}
		function lowerVolume() {
			Osd.lowerVolume()
		}
		function mute() {
			Osd.mute()
		}
		function muteSource() {
			Osd.muteSource()
		}
		function brightnessUp() {
			Osd.brightnessUp()
		}
		function brightnessDown() {
			Osd.brightnessDown()
		}
		function playPause() {
			Osd.playPause()
		}
		function stop() {
			Osd.stop()
		}
		function previous() {
			Osd.previous()
		}
		function next() {
			Osd.next()
		}
	}

	IpcHandler {
		target: "glance"

		function open() {
			Glance.show()
		}
	}

	IpcHandler {
		target: "notifications"

		function toggle() {
			Notifications.toggle()
		}
	}

	IpcHandler {
		target: "controls"

		function toggle() {
			Controls.toggle()
		}
	}

	IpcHandler {
		target: "launcher"

		function toggle() {
			Launcher.toggle()
		}
	}
}
