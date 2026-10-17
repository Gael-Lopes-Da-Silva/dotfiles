pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property bool primed: false
	property var seen: ({})
	property var fields: ({})

	function external(name) {
		return !/^(eDP|LVDS|DSI|Virtual)/.test(String(name || ""))
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

	function commitUsb() {
		const action = fields.ACTION || ""
		if (fields.DEVTYPE !== "usb_device")
			return
		if (action !== "add" && action !== "remove")
			return
		const model = pretty(fields.ID_MODEL_FROM_DATABASE || fields.ID_MODEL)
		const vendor = pretty(fields.ID_VENDOR_FROM_DATABASE || fields.ID_VENDOR)
		if (/root hub|host controller|\bhub\b/i.test(model) || /root hub|host controller|\bhub\b/i.test(vendor))
			return
		let name = vendor
		if (model && vendor && model.toLowerCase().indexOf(vendor.toLowerCase()) === -1)
			name = vendor + " " + model
		else
			name = model || vendor
		NiriState.showOsd("usb", name || "USB", action === "add")
	}

	function ingestUsb(line) {
		const text = String(line)
		if (text.indexOf("UDEV") === 0 || text.trim() === "") {
			commitUsb()
			fields = {}
			return
		}
		const eq = text.indexOf("=")
		if (eq <= 0)
			return
		const next = Object.assign({}, fields)
		next[text.slice(0, eq)] = text.slice(eq + 1)
		fields = next
	}

	Connections {
		target: Quickshell
		function onScreensChanged() {
			root.noteScreens()
		}
	}

	Timer {
		interval: 800
		running: true
		onTriggered: {
			root.noteScreens()
			root.primed = true
		}
	}

	Process {
		command: ["stdbuf", "-oL", "udevadm", "monitor", "--udev", "--subsystem-match=usb", "--property"]
		running: true
		stdout: SplitParser {
			onRead: line => root.ingestUsb(line)
		}
	}
}
