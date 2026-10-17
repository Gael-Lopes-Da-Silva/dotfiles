import QtQuick
import Quickshell
import Quickshell.Services.UPower

Item {
	id: root

	implicitWidth: row.implicitWidth + Theme.padding * 2
	implicitHeight: row.implicitHeight + Theme.padding * 2

	property string timeText: Qt.formatTime(clock.now, "HH:mm")

	readonly property var battery: UPower.displayDevice
	readonly property bool hasBattery: battery.ready && battery.isLaptopBattery && battery.isPresent
	readonly property int percent: Math.round(battery.percentage)
	readonly property bool charging: {
		const state = battery.state
		return state === UPowerDeviceState.Charging
			|| state === UPowerDeviceState.FullyCharged
			|| state === UPowerDeviceState.PendingCharge
	}

	function batteryGlyph() {
		if (!hasBattery)
			return ""
		if (charging && percent < 95)
			return String.fromCodePoint(0xF0084)
		if (percent >= 95)
			return String.fromCodePoint(0xF0079)
		if (percent >= 85)
			return String.fromCodePoint(0xF0082)
		if (percent >= 75)
			return String.fromCodePoint(0xF0081)
		if (percent >= 65)
			return String.fromCodePoint(0xF0080)
		if (percent >= 55)
			return String.fromCodePoint(0xF007F)
		if (percent >= 45)
			return String.fromCodePoint(0xF007E)
		if (percent >= 35)
			return String.fromCodePoint(0xF007D)
		if (percent >= 25)
			return String.fromCodePoint(0xF007C)
		if (percent >= 15)
			return String.fromCodePoint(0xF007B)
		if (percent >= 5)
			return String.fromCodePoint(0xF007A)
		return String.fromCodePoint(0xF008E)
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
			text: root.timeText
			color: Theme.foreground
			font.family: Theme.fontFamily
			font.pixelSize: Theme.clockSize
			anchors.verticalCenter: parent.verticalCenter
		}

		Text {
			visible: root.hasBattery
			text: root.batteryGlyph()
			color: Theme.foreground
			font.family: Theme.iconFont
			font.pixelSize: Theme.fontSize + 4
			anchors.verticalCenter: parent.verticalCenter
		}

		Text {
			visible: root.hasBattery
			text: root.percent + "%"
			color: Theme.foreground
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			anchors.verticalCenter: parent.verticalCenter
		}
	}
}
