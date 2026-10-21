// Battery level, remaining time, and power profile. Options live in config.json "battery".
import QtQuick
import Quickshell.Services.UPower
import qs.services
import qs.lib

Column {
	id: root

	spacing: 2

	function ink(alpha) {
		return Theme.ink(alpha)
	}

		Item {
			width: parent.width
			height: Config.battery.headerHeight

			Text {
				id: batteryTitle
				anchors.left: parent.left
				anchors.leftMargin: 18
				anchors.top: parent.top
				anchors.topMargin: 6
				text: "Battery"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Config.battery.titleSize
			}

			Text {
				anchors.right: parent.right
				anchors.rightMargin: 18
				anchors.baseline: batteryTitle.baseline
				text: PowerState.percent + "%"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Config.battery.titleSize
			}

			Rectangle {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.leftMargin: 18
				anchors.rightMargin: 18
				anchors.bottom: parent.bottom
				anchors.bottomMargin: 10
				height: Config.battery.barHeight
				radius: Config.battery.barHeight / 2
				color: root.ink(Theme.track)

				Rectangle {
					width: parent.width * Math.max(0, Math.min(1, PowerState.level))
					height: parent.height
					radius: parent.radius
					color: PowerState.percent <= Config.battery.lowPercent && !PowerState.plugged ? Theme.recording : Theme.foreground
				}
			}
		}

		Item {
			visible: !PowerState.plugged
			width: parent.width
			height: life.implicitHeight + 16

			Rectangle {
				anchors.fill: parent
				anchors.leftMargin: 8
				anchors.rightMargin: 8
				radius: Theme.rowRadius
				color: root.ink(Theme.wash)
			}

			Text {
				id: life
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: 18
				anchors.rightMargin: 18
				text: PowerState.lifeText()
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
				wrapMode: Text.WordWrap
			}
		}

		Repeater {
			model: PowerState.profiles

			Rectangle {
				id: profileRow
				required property var modelData
				readonly property bool active: PowerProfiles.profile === modelData.profile

				width: root.width - Theme.inset * 2
				x: Theme.inset
				height: Theme.rowInnerHeight
				radius: Theme.rowRadius
				color: profileHover.hovered ? root.ink(active ? Theme.buttonHover : Theme.hover) : (active ? root.ink(Theme.selected) : "transparent")

				Text {
					anchors.left: parent.left
					anchors.leftMargin: 14
					anchors.verticalCenter: parent.verticalCenter
					text: profileRow.modelData.label
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
				}

				Text {
					anchors.right: parent.right
					anchors.rightMargin: 14
					anchors.verticalCenter: parent.verticalCenter
					visible: profileRow.active
					text: "Active"
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.smallSize
				}

				HoverHandler {
					id: profileHover
				}

				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: PowerProfiles.profile = profileRow.modelData.profile
				}
			}
		}

		Text {
			visible: PowerState.limitText() !== ""
			width: parent.width
			text: PowerState.limitText()
			color: root.ink(Theme.quiet)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.smallSize
			wrapMode: Text.WordWrap
			leftPadding: 18
			rightPadding: 18
			topPadding: 6
			bottomPadding: 2
		}
}
