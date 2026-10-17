import QtQuick
import Quickshell
import Quickshell.Io

Item {
	id: root

	property bool open: false
	property string query: ""
	property int selected: 0

	readonly property int rowHeight: 48
	readonly property int iconSize: 26
	readonly property int textSize: Theme.fontSize + 4
	readonly property int fieldWidth: 440
	property var iconFiles: ({})
	readonly property var iconSizes: [
		"512x512", "512x512@2", "256x256", "256x256@2",
		"128x128", "128x128@2", "64x64", "48x48", "32x32"
	]
	readonly property var results: {
		const model = DesktopEntries.applications
		const apps = model && model.values ? model.values : []
		const q = query.trim().toLowerCase()
		const matched = []
		for (let i = 0; i < apps.length; i++) {
			const app = apps[i]
			const name = (app.name || "").toLowerCase()
			const generic = (app.genericName || "").toLowerCase()
			if (q === "" || name.indexOf(q) !== -1 || generic.indexOf(q) !== -1)
				matched.push(app)
		}
		matched.sort((a, b) => String(a.name).localeCompare(String(b.name)))
		return matched.slice(0, 8)
	}

	implicitWidth: column.implicitWidth + Theme.padding * 2
	implicitHeight: column.implicitHeight + Theme.padding * 2

	onResultsChanged: {
		if (selected >= results.length)
			selected = 0
		resolveIcons()
	}

	function resolveIcons() {
		if (!files)
			return
		const next = Object.assign({}, iconFiles)
		let changed = false
		for (let i = 0; i < results.length; i++) {
			const name = results[i].icon || "application-x-executable"
			if (next[name])
				continue
			next[name] = locateIcon(name)
			changed = true
		}
		if (changed)
			iconFiles = next
	}

	function iconSource(name) {
		const url = iconFiles[name || ""] || ""
		if (url)
			return url
		return Quickshell.iconPath(name || "", "application-x-executable")
	}

	function locateIcon(name) {
		if (name.charAt(0) === "/" || name.indexOf("file://") === 0) {
			const path = name.replace(/^file:\/\//, "")
			const direct = iconUrl(path)
			if (direct)
				return direct
		}

		const raw = Quickshell.env("XDG_DATA_DIRS")
		const dirs = raw ? String(raw).split(":") : []
		for (let d = 0; d < dirs.length; d++) {
			const dir = dirs[d]
			if (!dir)
				continue
			for (let s = 0; s < iconSizes.length; s++) {
				const png = dir + "/icons/hicolor/" + iconSizes[s] + "/apps/" + name + ".png"
				if (fileExists(png))
					return "file://" + png
			}
			const svg = iconUrl(dir + "/icons/hicolor/scalable/apps/" + name + ".svg")
			if (svg)
				return svg
			const pix = dir + "/pixmaps/" + name + ".png"
			if (fileExists(pix))
				return "file://" + pix
		}
		return Quickshell.iconPath(name, "application-x-executable")
	}

	// Qt paints <clipPath> geometry and enable-background as an opaque black square.
	function iconUrl(path) {
		if (path.slice(-4) !== ".svg" && path.slice(-5) !== ".svgz")
			return fileExists(path) ? "file://" + path : ""
		if (path.slice(-5) === ".svgz")
			return fileExists(path) ? "file://" + path : ""
		const text = readText(path)
		if (!text)
			return ""
		if (text.indexOf("clipPath") === -1 && text.indexOf("enable-background") === -1)
			return "file://" + path
		const cleaned = text
			.replace(/enable-background\s*=\s*"[^"]*"/gi, "")
			.replace(/enable-background\s*:\s*[^;"]*/gi, "")
			.replace(/<clipPath\b[^>]*>[\s\S]*?<\/clipPath>/gi, "")
		return "data:image/svg+xml;base64," + base64(cleaned)
	}

	function fileExists(path) {
		files.path = path
		const data = files.data()
		const size = data ? (data.byteLength || data.length || 0) : 0
		return files.loaded && size > 0
	}

	function readText(path) {
		files.path = path
		const text = files.text()
		return files.loaded ? text : ""
	}

	function base64(text) {
		const bytes = []
		for (let i = 0; i < text.length; i++) {
			let c = text.charCodeAt(i)
			if (c < 0x80)
				bytes.push(c)
			else if (c < 0x800)
				bytes.push(0xc0 | (c >> 6), 0x80 | (c & 63))
			else if (c >= 0xd800 && c <= 0xdbff && i + 1 < text.length) {
				const u = 0x10000 + ((c & 0x3ff) << 10) + (text.charCodeAt(++i) & 0x3ff)
				bytes.push(0xf0 | (u >> 18), 0x80 | ((u >> 12) & 63), 0x80 | ((u >> 6) & 63), 0x80 | (u & 63))
			} else
				bytes.push(0xe0 | (c >> 12), 0x80 | ((c >> 6) & 63), 0x80 | (c & 63))
		}
		return Qt.btoa(bytes)
	}

	FileView {
		id: files
		preload: false
		blockAllReads: true
		printErrors: false
	}

	Component.onCompleted: resolveIcons()

	onOpenChanged: {
		if (open)
			Qt.callLater(() => search.forceActiveFocus())
		else {
			query = ""
			selected = 0
		}
	}

	function activate(index) {
		const app = results[index]
		if (!app)
			return
		app.execute()
		NiriState.closeLauncher()
	}

	function move(step) {
		if (results.length === 0)
			return
		const last = results.length - 1
		selected = Math.max(0, Math.min(last, selected + step))
	}

	Column {
		id: column
		width: root.fieldWidth
		anchors.bottom: parent.bottom
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottomMargin: Theme.padding
		spacing: 2

		Repeater {
			model: root.results

			Rectangle {
				id: appRow
				required property var modelData
				required property int index
				readonly property bool chosen: index === root.selected
				readonly property string detail: {
					const generic = modelData.genericName || ""
					if (!generic || generic === modelData.name)
						return ""
					return generic
				}

				width: root.fieldWidth
				height: detail === "" ? root.rowHeight : root.rowHeight + 8
				radius: 12
				color: chosen ? Theme.ink(0.12) : "transparent"

				Image {
					id: appIcon
					anchors.left: parent.left
					anchors.leftMargin: 12
					anchors.verticalCenter: parent.verticalCenter
					source: root.iconSource(appRow.modelData.icon || "application-x-executable")
					width: root.iconSize
					height: root.iconSize
					sourceSize.width: root.iconSize * 2
					sourceSize.height: root.iconSize * 2
					fillMode: Image.PreserveAspectFit
					smooth: true
					mipmap: true
				}

				Column {
					anchors.left: appIcon.right
					anchors.leftMargin: 12
					anchors.right: parent.right
					anchors.rightMargin: 14
					anchors.verticalCenter: parent.verticalCenter
					spacing: 1

					Text {
						width: parent.width
						text: appRow.modelData.name
						color: Theme.foreground
						font.family: Theme.fontFamily
						font.pixelSize: root.textSize
						elide: Text.ElideRight
					}

					Text {
						width: parent.width
						visible: appRow.detail !== ""
						text: appRow.detail
						color: Theme.ink(0.5)
						font.family: Theme.fontFamily
						font.pixelSize: Theme.fontSize
						elide: Text.ElideRight
					}
				}

				MouseArea {
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onEntered: root.selected = index
					onClicked: root.activate(index)
				}
			}
		}

		Text {
			visible: root.results.length === 0 && root.query.trim() !== ""
			text: "No matches"
			color: Theme.ink(0.45)
			font.family: Theme.fontFamily
			font.pixelSize: root.textSize
			width: root.fieldWidth
			horizontalAlignment: Text.AlignHCenter
			topPadding: 12
			bottomPadding: 12
		}

		Item {
			width: root.fieldWidth
			height: 12
		}

		Rectangle {
			width: root.fieldWidth
			height: 48
			radius: 14
			color: Theme.ink(0.08)

			Text {
				anchors.left: parent.left
				anchors.leftMargin: 16
				anchors.verticalCenter: parent.verticalCenter
				text: String.fromCodePoint(0xF0349)
				color: Theme.ink(0.55)
				font.family: Theme.iconFont
				font.pixelSize: 18
			}

			TextInput {
				id: search
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: 44
				anchors.rightMargin: 16
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: root.textSize
				clip: true
				selectByMouse: true
				text: root.query
				onTextChanged: root.query = text

				Keys.onUpPressed: event => {
					root.move(-1)
					event.accepted = true
				}
				Keys.onDownPressed: event => {
					root.move(1)
					event.accepted = true
				}
				Keys.onReturnPressed: event => {
					root.activate(root.selected)
					event.accepted = true
				}
				Keys.onEnterPressed: event => {
					root.activate(root.selected)
					event.accepted = true
				}
				Keys.onEscapePressed: event => {
					NiriState.closeLauncher()
					event.accepted = true
				}
			}

			Text {
				anchors.left: search.left
				anchors.verticalCenter: search.verticalCenter
				text: "Search"
				visible: search.text.length === 0
				color: Theme.ink(0.4)
				font: search.font
			}
		}
	}
}
