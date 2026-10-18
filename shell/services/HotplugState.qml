pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.settings

Singleton {
	id: root

	property bool primed: false
	property var seen: ({})
	property string diskBatch: ""
	property string diskState: ""
	property bool disksPrimed: false

	function external(name) {
		return !new RegExp(Config.internalScreens).test(String(name || ""))
	}

	function screenLabel(screen) {
		const model = String(screen.model || "")
		if (model && !/^0x/i.test(model))
			return model
		return screen.name
	}

	function snapshot() {
		const next = {}
		const screens = Quickshell.screens
		for (let i = 0; i < screens.length; i++) {
			const screen = screens[i]
			if (!external(screen.name))
				continue
			next[screen.name] = screenLabel(screen)
		}
		return next
	}

	function noteScreens() {
		const next = snapshot()
		if (!primed) {
			seen = next
			return
		}
		const names = Object.keys(next)
		for (let i = 0; i < names.length; i++) {
			if (!seen[names[i]])
				NiriState.showOsd("screen", next[names[i]] || names[i], true)
		}
		const gone = Object.keys(seen)
		for (let i = 0; i < gone.length; i++) {
			if (!next[gone[i]])
				NiriState.showOsd("screen", seen[gone[i]] || gone[i], false)
		}
		seen = next
	}

	function pretty(value) {
		return String(value || "").replace(/_/g, " ").trim()
	}

	function diskLabel(name) {
		let text = String(name || "").replace(/^usb-/, "")
		text = text.replace(/-[0-9]+:[0-9]+$/, "")
		const parts = text.split("_")
		if (parts.length > 2 && /^[A-Z0-9]{8,}$/.test(parts[parts.length - 1]))
			parts.pop()
		return pretty(parts.join(" ")) || "USB"
	}

	function diskMap(state) {
		const map = {}
		const lines = String(state || "").split("\n")
		for (let i = 0; i < lines.length; i++) {
			const line = lines[i]
			if (!line)
				continue
			const tab = line.indexOf("\t")
			if (tab < 0)
				continue
			map[line.slice(0, tab)] = line.slice(tab + 1)
		}
		return map
	}

	function takeDisk(line) {
		const name = String(line).trim()
		if (name.indexOf("usb-") !== 0 || /-part\d+$/.test(name))
			return
		const key = name.replace(/-[0-9]+:[0-9]+$/, "")
		if (diskBatch.indexOf(key + "\t") !== -1)
			return
		diskBatch = diskBatch + key + "\t" + diskLabel(key) + "\n"
	}

	function finishDisks() {
		const next = diskMap(diskBatch)
		if (!disksPrimed) {
			diskState = diskBatch
			disksPrimed = true
			return
		}
		const prev = diskMap(diskState)
		const arrived = Object.keys(next)
		for (let i = 0; i < arrived.length; i++) {
			if (!prev[arrived[i]])
				NiriState.showOsd("usb", next[arrived[i]] || "USB", true)
		}
		const gone = Object.keys(prev)
		for (let i = 0; i < gone.length; i++) {
			if (!next[gone[i]])
				NiriState.showOsd("usb", prev[gone[i]] || "USB", false)
		}
		diskState = diskBatch
	}

	Connections {
		target: Quickshell
		function onScreensChanged() {
			root.noteScreens()
		}
	}

	Timer {
		interval: Config.screenPrime
		running: true
		onTriggered: {
			root.noteScreens()
			root.primed = true
		}
	}

	Process {
		id: disks
		command: ["ls", "-1", "/dev/disk/by-id"]
		stdout: SplitParser {
			onRead: line => root.takeDisk(line)
		}
		onExited: code => {
			if (code === 0)
				root.finishDisks()
		}
	}

	Timer {
		interval: Config.usbPoll
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			if (disks.running)
				return
			root.diskBatch = ""
			disks.running = true
		}
	}
}
