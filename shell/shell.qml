import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import qs.overlay
import qs.services

ShellRoot {
	// Singletons are created on first use. Keep the watchers alive from startup
	// so brightness and charger changes are seen before an OSD is open.
	readonly property real backlight: BrightnessState.level
	readonly property bool powerPlugged: PowerState.plugged
	readonly property bool wifiEnabled: Networking.wifiEnabled
	readonly property bool bluetoothOn: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
	readonly property int noticeCount: NoticeState.count
	readonly property bool devicesReady: HotplugState.primed

	Variants {
		model: Quickshell.screens

		Scope {
			id: screenScope
			required property var modelData

			Wallpaper {
				screen: screenScope.modelData
			}

			ScreenOverlay {
				modelData: screenScope.modelData
			}
		}
	}

	IpcHandler {
		target: "launcher"
		function toggle() {
			NiriState.toggleLauncher()
		}
	}

	IpcHandler {
		target: "interface"
		function toggle() {
			NiriState.toggleHidden()
		}
	}
}
