// Loads config.json and exposes one object per section.
// Edit config.json to change a value. This file does not repeat those values.

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property var data: ({})

	readonly property var theme: data.theme || ({})
	readonly property var frame: data.frame || ({})
	readonly property var status: data.status || ({})
	readonly property var clock: data.clock || ({})
	readonly property var battery: data.battery || ({})
	readonly property var notices: data.notices || ({})
	readonly property var cast: data.cast || ({})
	readonly property var osd: data.osd || ({})
	readonly property var launcher: data.launcher || ({})
	readonly property var radio: data.radio || ({})
	readonly property var audio: data.audio || ({})
	readonly property var session: data.session || ({})
	readonly property var niri: data.niri || ({})
	readonly property var brightness: data.brightness || ({})
	readonly property var hotplug: data.hotplug || ({})

	readonly property var sections: [
		"theme", "frame", "status", "clock", "battery", "notices", "cast", "osd",
		"launcher", "radio", "audio", "session", "niri", "brightness", "hotplug"
	]

	// Nerd Font codepoint ("F0150") to the glyph string widgets draw.
	function icon(code) {
		return String.fromCodePoint(parseInt(code, 16))
	}

	// config.json allows comments. Qt's parser does not, so they are removed first.
	function strip(text) {
		let out = ""
		let quote = ""
		for (let i = 0; i < text.length; i++) {
			const c = text[i]
			const next = i + 1 < text.length ? text[i + 1] : ""
			if (quote) {
				out += c
				if (c === "\\") {
					if (next)
						out += next
					i++
					continue
				}
				if (c === quote)
					quote = ""
				continue
			}
			if (c === "\"" || c === "'") {
				quote = c
				out += c
				continue
			}
			if (c === "/" && next === "/") {
				while (i < text.length && text[i] !== "\n")
					i++
				out += "\n"
				continue
			}
			if (c === "/" && next === "*") {
				i += 2
				while (i < text.length && !(text[i] === "*" && text[i + 1] === "/"))
					i++
				i++
				continue
			}
			out += c
		}
		return out
	}

	function read() {
		let raw = ""
		try {
			raw = view.text()
		} catch (e) {
			return
		}
		raw = strip(raw || "").trim()
		if (!raw)
			return
		let parsed
		try {
			parsed = JSON.parse(raw)
		} catch (e) {
			console.warn("config.json:", e)
			return
		}
		for (let i = 0; i < sections.length; i++) {
			if (!parsed[sections[i]])
				console.warn("config.json is missing the \"" + sections[i] + "\" section")
		}
		data = parsed
	}

	FileView {
		id: view
		path: Quickshell.shellPath("config.json")
		watchChanges: true
		preload: true
		blockLoading: true
		printErrors: true
		onLoaded: root.read()
		onFileChanged: reload()
	}

	Component.onCompleted: read()
}
