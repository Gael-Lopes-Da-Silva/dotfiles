import QtQuick
import Quickshell
import qs
import qs.services

Item {
	id: root

	signal timeClicked()
	signal batteryClicked()
	signal noticesClicked()

	property string activePage: ""
	readonly property real buttonPadX: Theme.chipPadX
	readonly property real buttonPadY: Theme.chipPadY
	readonly property real buttonGap: Theme.chipGap
	readonly property real noticeWidth: Math.max(timeRow.implicitHeight + buttonPadY * 2, noticeRow.implicitWidth + buttonPadX * 2)
	readonly property real contentWidth: noticeWidth + buttonGap + timeRow.implicitWidth + buttonPadX * 2 + (batteryHit.visible ? buttonGap + batteryRow.implicitWidth + buttonPadX * 2 : 0)
	readonly property real contentHeight: Math.max(timeRow.implicitHeight, noticeRow.implicitHeight, batteryHit.visible ? batteryRow.implicitHeight : 0)

	implicitWidth: contentWidth + (Theme.padding - buttonPadX) + Theme.padding
	implicitHeight: contentHeight + Theme.padding * 2

	property string timeText: Qt.formatTime(clock.now, Config.timeFormat)

	function clockGlyph() {
		return String.fromCodePoint(0xF0150)
	}

	QtObject {
		id: clock
		property date now: new Date()
	}

	Timer {
		interval: Config.clockTick
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: clock.now = new Date()
	}

	Row {
		id: row
		anchors.right: parent.right
		anchors.rightMargin: Theme.padding
		anchors.verticalCenter: parent.verticalCenter
		spacing: root.buttonGap

		Item {
			implicitWidth: timeRow.implicitWidth + root.buttonPadX * 2
			implicitHeight: timeRow.implicitHeight + root.buttonPadY * 2

			Rectangle {
				anchors.fill: parent
				radius: Theme.buttonRadius
				color: {
					if (timeHover.containsMouse)
						return Theme.ink(root.activePage === "time" ? Theme.buttonHover : Theme.hover)
					return root.activePage === "time" ? Theme.ink(Theme.selected) : "transparent"
				}
			}

			Row {
				id: timeRow
				anchors.centerIn: parent
				spacing: Theme.gap

				Text {
					text: root.clockGlyph()
					color: Theme.foreground
					font.family: Theme.iconFont
					font.pixelSize: Theme.clockSize
					anchors.verticalCenter: parent.verticalCenter
				}

				Text {
					text: root.timeText
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.clockSize
					anchors.verticalCenter: parent.verticalCenter
				}
			}

			MouseArea {
				id: timeHover
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: root.timeClicked()
			}
		}

		Item {
			id: batteryHit
			visible: PowerState.hasBattery
			implicitWidth: batteryRow.implicitWidth + root.buttonPadX * 2
			implicitHeight: batteryRow.implicitHeight + root.buttonPadY * 2

			Rectangle {
				anchors.fill: parent
				radius: Theme.buttonRadius
				color: {
					if (batteryHover.containsMouse)
						return Theme.ink(root.activePage === "battery" ? Theme.buttonHover : Theme.hover)
					return root.activePage === "battery" ? Theme.ink(Theme.selected) : "transparent"
				}
			}

			Row {
				id: batteryRow
				anchors.centerIn: parent
				spacing: Theme.gap

				Text {
					text: PowerState.batteryGlyph()
					color: Theme.foreground
					font.family: Theme.iconFont
					font.pixelSize: Theme.clockSize
					anchors.verticalCenter: parent.verticalCenter
				}

				Text {
					text: PowerState.percent + "%"
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.clockSize
					anchors.verticalCenter: parent.verticalCenter
				}
			}

			MouseArea {
				id: batteryHover
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: root.batteryClicked()
			}
		}

		Item {
			id: noticeHit
			implicitWidth: root.noticeWidth
			implicitHeight: timeRow.implicitHeight + root.buttonPadY * 2

			Rectangle {
				anchors.fill: parent
				radius: Theme.buttonRadius
				color: {
					if (noticeHover.containsMouse)
						return Theme.ink(root.activePage === "notices" ? Theme.buttonHover : Theme.hover)
					return root.activePage === "notices" ? Theme.ink(Theme.selected) : "transparent"
				}
			}

			Row {
				id: noticeRow
				anchors.centerIn: parent
				spacing: Theme.gap

				Text {
					text: String.fromCodePoint(NoticeState.quiet ? 0xF00A0 : 0xF009A)
					color: Theme.foreground
					font.family: Theme.iconFont
					font.pixelSize: Theme.clockSize
					anchors.verticalCenter: parent.verticalCenter
				}

				Text {
					visible: NoticeState.historyCount > 0
					text: NoticeState.historyCount
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.clockSize
					anchors.verticalCenter: parent.verticalCenter
				}
			}

			MouseArea {
				id: noticeHover
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: root.noticesClicked()
			}
		}
	}
}
