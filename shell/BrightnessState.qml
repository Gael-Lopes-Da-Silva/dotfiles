pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property real level: 0
	property bool available: false
	property bool primed: false
	property bool watching: true

	function apply(line) {
		const parts = String(line).trim().split(",")
		if (parts.length < 5)
			return
		const cur = parseInt(parts[2], 10)
		const max = parseInt(parts[4], 10)
		if (!Number.isFinite(cur) || !Number.isFinite(max) || max <= 0)
			return
		available = true
		const next = cur / max
		const changed = Math.abs(next - level) > 0.002
		level = next
		if (!primed) {
			primed = true
			return
		}
		if (changed)
			NiriState.showOsd("brightness")
	}

	Process {
		id: scan
		stdout: StdioCollector {
			onStreamFinished: root.apply(this.text)
		}
		onExited: code => {
			if (code !== 0)
				root.watching = false
		}
	}

	Timer {
		interval: 250
		running: root.watching
		repeat: true
		triggeredOnStart: true
		onTriggered: scan.exec(["brightnessctl", "--class=backlight", "-m"])
	}
}
