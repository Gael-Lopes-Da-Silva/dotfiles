import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking

ShellRoot {
	// Singletons are created on first use. Keep the watchers alive from startup
	// so brightness and charger changes are seen before an OSD is open.
	readonly property real backlight: BrightnessState.level
	readonly property bool powerPlugged: PowerState.plugged
	readonly property bool wifiEnabled: Networking.wifiEnabled
	readonly property bool bluetoothOn: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false
	readonly property int noticeCount: NoticeState.count

	Variants {
		model: Quickshell.screens
		ScreenOverlay {}
	}

	IpcHandler {
		target: "launcher"
		function toggle() {
			NiriState.toggleLauncher()
		}
	}
}
