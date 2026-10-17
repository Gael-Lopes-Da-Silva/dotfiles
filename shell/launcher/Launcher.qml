pragma Singleton

import QtQuick
import Quickshell
import qs
import qs.common

Item {
	id: launcher

	property string query: ""
	property int index: 0

	readonly property var results: {
		const q = query.trim().toLowerCase()
		const apps = DesktopEntries.applications.values
		const list = []
		for (let i = 0; i < apps.length; i++) {
			const entry = apps[i]
			if (entry.noDisplay)
				continue
			const name = (entry.name || "").toLowerCase()
			const generic = (entry.genericName || "").toLowerCase()
			if (q && !name.includes(q) && !generic.includes(q))
				continue
			list.push(entry)
		}
		list.sort((a, b) => (a.name || "").localeCompare(b.name || ""))
		return list.slice(0, 8)
	}

	onQueryChanged: index = 0

	function toggle() {
		if (surface.shown)
			surface.dismiss()
		else
			show()
	}

	function show() {
		query = ""
		index = 0
		surface.summon()
	}

	function move(delta) {
		if (results.length === 0)
			return
		index = (index + delta + results.length) % results.length
	}

	function launch() {
		const entry = results[index]
		if (!entry)
			return
		entry.execute()
		surface.dismiss()
	}

	Surface {
		id: surface
		lifetime: "session"
		edge: "center"
		wantsKeyboard: true
		namespace: "launcher"

		content: Rectangle {
			implicitWidth: 420
			implicitHeight: column.implicitHeight + Theme.padding * 2
			radius: Theme.radius
			color: Theme.background
			border.color: Theme.border
			border.width: 1

			Column {
				id: column
				x: Theme.padding
				y: Theme.padding
				width: 420 - Theme.padding * 2
				spacing: 8

				Rectangle {
					width: parent.width
					height: field.implicitHeight + 16
					radius: 8
					color: "transparent"
					border.color: Theme.border
					border.width: 1

					TextInput {
						id: field
						anchors.fill: parent
						anchors.margins: 8
						focus: true
						color: Theme.foreground
						font.family: Theme.fontFamily
						font.pixelSize: Theme.fontSize
						clip: true
						selectByMouse: true
						text: launcher.query
						onTextChanged: launcher.query = text

						Keys.onUpPressed: event => {
							launcher.move(-1)
							event.accepted = true
						}
						Keys.onDownPressed: event => {
							launcher.move(1)
							event.accepted = true
						}
						Keys.onReturnPressed: launcher.launch()
						Keys.onEnterPressed: launcher.launch()
						Keys.onEscapePressed: surface.dismiss()
					}

					Text {
						anchors.left: parent.left
						anchors.leftMargin: 8
						anchors.verticalCenter: parent.verticalCenter
						visible: field.text.length === 0
						text: "Search"
						color: Theme.muted
						font.family: Theme.fontFamily
						font.pixelSize: Theme.fontSize
					}
				}

				Repeater {
					model: launcher.results

					Rectangle {
						id: row
						required property int index
						required property var modelData
						width: column.width
						height: 32
						radius: 8
						color: index === launcher.index ? Theme.border : "transparent"

						Text {
							anchors.verticalCenter: parent.verticalCenter
							anchors.left: parent.left
							anchors.leftMargin: 8
							width: parent.width - 16
							text: row.modelData.name
							color: Theme.foreground
							font.family: Theme.fontFamily
							font.pixelSize: Theme.fontSize
							elide: Text.ElideRight
						}

						MouseArea {
							anchors.fill: parent
							onClicked: {
								launcher.index = row.index
								launcher.launch()
							}
						}
					}
				}
			}
		}
	}
}
