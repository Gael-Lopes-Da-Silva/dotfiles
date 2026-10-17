pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

Singleton {
	id: root

	property bool primed: false
	property bool pluggedSeen: false

	readonly property var battery: UPower.displayDevice
	readonly property bool hasBattery: battery.ready && battery.isLaptopBattery && battery.isPresent
	readonly property bool plugged: hasBattery && !UPower.onBattery
	// UPower reports charge as a 0–1 fraction.
	readonly property real level: hasBattery ? battery.percentage : 0
	readonly property int percent: hasBattery ? Math.round(level * 100) : 0

	function batteryGlyph() {
		if (!hasBattery)
			return ""
		if (plugged) {
			if (percent >= 95)
				return String.fromCodePoint(0xF0085)
			if (percent >= 85)
				return String.fromCodePoint(0xF008B)
			if (percent >= 75)
				return String.fromCodePoint(0xF008A)
			if (percent >= 65)
				return String.fromCodePoint(0xF089E)
			if (percent >= 55)
				return String.fromCodePoint(0xF0089)
			if (percent >= 45)
				return String.fromCodePoint(0xF089D)
			if (percent >= 35)
				return String.fromCodePoint(0xF0088)
			if (percent >= 25)
				return String.fromCodePoint(0xF0087)
			if (percent >= 15)
				return String.fromCodePoint(0xF0086)
			if (percent >= 5)
				return String.fromCodePoint(0xF089C)
			return String.fromCodePoint(0xF0084)
		}
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

	function note() {
		if (!primed || !hasBattery || plugged === pluggedSeen)
			return
		pluggedSeen = plugged
		NiriState.showOsd("power")
	}

	onPluggedChanged: note()

	Timer {
		id: arm
		interval: 400
		onTriggered: {
			root.pluggedSeen = root.plugged
			root.primed = true
		}
	}

	Component.onCompleted: arm.restart()
	onHasBatteryChanged: {
		if (!primed)
			arm.restart()
	}
}
