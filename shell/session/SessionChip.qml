import QtQuick
import qs.settings

Item {
	id: root

	signal powerClicked()
	signal shotClicked()

	property bool powerOpen: false

	implicitWidth: row.implicitWidth + Theme.padding * 2
	implicitHeight: row.implicitHeight + Theme.padding * 2
	width: implicitWidth
	height: implicitHeight

	readonly property real buttonSize: {
		const side = Math.max(powerIcon.implicitWidth, powerIcon.implicitHeight, shotIcon.implicitWidth, shotIcon.implicitHeight)
		return side + Theme.padding
	}

	Row {
		id: row
		anchors.centerIn: parent
		spacing: Theme.gap

		Item {
			implicitWidth: root.buttonSize
			implicitHeight: root.buttonSize
			width: implicitWidth
			height: implicitHeight

			Rectangle {
				anchors.fill: parent
				radius: Theme.buttonRadius
				color: shotHover.containsMouse ? Theme.ink(Theme.hover) : "transparent"
			}

			Text {
				id: shotIcon
				anchors.centerIn: parent
				text: Config.icon(Config.screenshot)
				color: Theme.foreground
				font.family: Theme.iconFont
				font.pixelSize: Theme.clockSize
			}

			MouseArea {
				id: shotHover
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: root.shotClicked()
			}
		}

		Item {
			implicitWidth: root.buttonSize
			implicitHeight: root.buttonSize
			width: implicitWidth
			height: implicitHeight

			Rectangle {
				anchors.fill: parent
				radius: Theme.buttonRadius
				color: {
					if (powerHover.containsMouse)
						return Theme.ink(root.powerOpen ? Theme.buttonHover : Theme.hover)
					return root.powerOpen ? Theme.ink(Theme.selected) : "transparent"
				}
			}

			Text {
				id: powerIcon
				anchors.centerIn: parent
				text: Config.icon(Config.power)
				color: Theme.foreground
				font.family: Theme.iconFont
				font.pixelSize: Theme.clockSize
			}

			MouseArea {
				id: powerHover
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: root.powerClicked()
			}
		}
	}
}
