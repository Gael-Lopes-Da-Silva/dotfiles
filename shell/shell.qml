import Quickshell
import Quickshell.Io

ShellRoot {
	// Singletons are created on first use. Keep the watchers alive from startup
	// so brightness and charger changes are seen before an OSD is open.
	readonly property real backlight: BrightnessState.level
	readonly property bool powerPlugged: PowerState.plugged

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
