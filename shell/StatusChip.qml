import QtQuick
import Quickshell

Item {
	id: root

	implicitWidth: row.implicitWidth + Theme.padding * 2
	implicitHeight: row.implicitHeight + Theme.padding * 2

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

		Text {
			visible: PowerState.hasBattery
			text: PowerState.batteryGlyph()
			color: Theme.foreground
			font.family: Theme.iconFont
			font.pixelSize: Theme.clockSize
			anchors.verticalCenter: parent.verticalCenter
		}

		Text {
			visible: PowerState.hasBattery
			text: PowerState.percent + "%"
			color: Theme.foreground
			font.family: Theme.fontFamily
			font.pixelSize: Theme.clockSize
			anchors.verticalCenter: parent.verticalCenter
		}
	}
}
