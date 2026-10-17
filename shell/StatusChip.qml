import QtQuick
import Quickshell

Item {
	id: root

	signal timeClicked()
	signal batteryClicked()

	property string activePage: ""
	readonly property real buttonPadX: 8
	readonly property real buttonPadY: 2
	readonly property real buttonGap: 8
	readonly property real contentWidth: timeRow.implicitWidth + buttonPadX * 2 + (batteryHit.visible ? buttonGap + batteryRow.implicitWidth + buttonPadX * 2 : 0)
	readonly property real contentHeight: Math.max(timeRow.implicitHeight, batteryHit.visible ? batteryRow.implicitHeight : 0)

	implicitWidth: contentWidth + (Theme.padding - buttonPadX) + Theme.padding
	implicitHeight: contentHeight + Theme.padding * 2

	property string timeText: Qt.formatTime(clock.now, "HH:mm")

	function clockGlyph() {
		return String.fromCodePoint(0xF0150)
	}

	QtObject {
		id: clock
		property date now: new Date()
	}

	Timer {
		interval: 1000
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
				radius: 8
				color: root.activePage === "time" ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
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
				anchors.fill: parent
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
				radius: 8
				color: root.activePage === "battery" ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
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
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: root.batteryClicked()
			}
		}
	}
}
