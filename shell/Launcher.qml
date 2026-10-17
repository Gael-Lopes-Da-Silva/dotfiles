import QtQuick
import Quickshell
import Quickshell.Widgets

Item {
	id: root

	property bool open: false
	property string query: ""
	property int selected: 0

	readonly property int rowHeight: 42
	readonly property int fieldWidth: 440
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
	}

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
		spacing: 4

		Repeater {
			model: root.results

			Rectangle {
				required property var modelData
				required property int index

				width: root.fieldWidth
				height: root.rowHeight
				radius: Theme.radius
				color: index === root.selected ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

				Row {
					anchors.fill: parent
					anchors.leftMargin: 10
					anchors.rightMargin: 10
					spacing: Theme.gap

					IconImage {
						source: Quickshell.iconPath(modelData.icon || "", "application-x-executable")
						implicitSize: 22
						anchors.verticalCenter: parent.verticalCenter
					}

					Text {
						text: modelData.name
						color: Theme.foreground
						font.family: Theme.fontFamily
						font.pixelSize: Theme.fontSize
						elide: Text.ElideRight
						width: parent.width - 22 - Theme.gap
						anchors.verticalCenter: parent.verticalCenter
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
			color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.55)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			width: root.fieldWidth
			leftPadding: 10
			topPadding: 8
			bottomPadding: 8
		}

		Item {
			width: root.fieldWidth
			height: search.implicitHeight + 16

			TextInput {
				id: search
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: 10
				anchors.rightMargin: 10
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
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
				color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.45)
				font: search.font
			}
		}
	}
}
