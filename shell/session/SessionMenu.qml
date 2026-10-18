import QtQuick
import Quickshell
import qs

Item {
	id: root

	signal chosen()

	implicitWidth: Theme.sessionMenuWidth
	implicitHeight: column.implicitHeight + Theme.padding
	width: implicitWidth
	height: implicitHeight

	function run(command) {
		Quickshell.execDetached(command)
		chosen()
	}

	Column {
		id: column
		width: parent.width
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: parent.bottom
		anchors.bottomMargin: Theme.padding * 0.5
		spacing: Theme.menuSpacing

		Repeater {
			model: [
				{ icon: 0xF0904, label: "Suspend", command: ["systemctl", "suspend"] },
				{ icon: 0xF0709, label: "Restart", command: ["systemctl", "reboot"] },
				{ icon: 0xF0425, label: "Shut down", command: ["systemctl", "poweroff"] },
				{ icon: 0xF0343, label: "Log out", command: ["niri", "msg", "action", "quit", "--skip-confirmation"] }
			]

			Rectangle {
				id: actionRow
				required property var modelData

				width: root.width - Theme.inset * 2
				x: Theme.inset
				height: Theme.rowInnerHeight
				radius: Theme.rowRadius
				color: actionHover.containsMouse ? Theme.ink(Theme.hover) : "transparent"

				Rectangle {
					id: well
					anchors.left: parent.left
					anchors.leftMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					width: Theme.well
					height: Theme.well
					radius: Theme.buttonRadius
					color: Theme.ink(Theme.wellFill)

					Text {
						anchors.centerIn: parent
						text: String.fromCodePoint(actionRow.modelData.icon)
						color: Theme.foreground
						font.family: Theme.iconFont
						font.pixelSize: Theme.glyphSize
					}
				}

				Text {
					anchors.left: well.right
					anchors.leftMargin: Theme.inset
					anchors.right: parent.right
					anchors.rightMargin: 12
					anchors.verticalCenter: parent.verticalCenter
					text: actionRow.modelData.label
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
					elide: Text.ElideRight
				}

				MouseArea {
					id: actionHover
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: root.run(actionRow.modelData.command)
				}
			}
		}
	}
}
