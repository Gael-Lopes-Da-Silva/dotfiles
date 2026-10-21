// Power actions opened from the session chip. Options live in config.json "session".
import QtQuick
import Quickshell
import qs.lib

Item {
	id: root

	signal chosen()

	implicitWidth: Config.session.menuWidth
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
			model: Config.session.actions

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
					width: Theme.iconWell
					height: Theme.iconWell
					radius: Theme.buttonRadius
					color: Theme.ink(Theme.wellFill)

					Text {
						anchors.centerIn: parent
						text: Config.icon(actionRow.modelData.icon)
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
