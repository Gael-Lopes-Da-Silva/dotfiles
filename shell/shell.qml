import Quickshell
import Quickshell.Io

ShellRoot {
	// Singletons are created on first use. The OSD only reads brightness while
	// that kind is showing, so keep the watcher alive from startup.
	readonly property real backlight: BrightnessState.level

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
