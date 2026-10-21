import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import qs.overlay
import qs.services

ShellRoot {
	readonly property int noticeCount: NoticeState.count
	readonly property real backlight: BrightnessState.level
	readonly property bool powerPlugged: PowerState.plugged
	readonly property bool audioSettled: AudioState.settled
	readonly property bool devicesReady: HotplugState.primed
	readonly property bool wifiEnabled: Networking.wifiEnabled
	readonly property bool radiosWarm: RadioState.wifiWarm && RadioState.btWarm
	readonly property bool bluetoothOn: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled : false

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
