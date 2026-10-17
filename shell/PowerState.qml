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

	property string menuOutput: ""
	property string menuPage: ""

	readonly property var profiles: {
		const list = [
			{ label: "Power saver", profile: PowerProfile.PowerSaver },
			{ label: "Balanced", profile: PowerProfile.Balanced }
		]
		if (PowerProfiles.hasPerformanceProfile)
			list.push({ label: "Performance", profile: PowerProfile.Performance })
		return list
	}

	function toggleMenu(output, page) {
		if (menuOutput === output && menuPage === page) {
			closeMenu()
			return
		}
		menuOutput = output
		menuPage = page
	}

	function closeMenu() {
		menuOutput = ""
		menuPage = ""
	}

	function lifeText() {
		if (!hasBattery || plugged)
			return ""
		const total = Math.round(battery.timeToEmpty || 0)
		if (total <= 0)
			return "Estimating remaining time"
		if (total < 60)
			return "Less than a minute remaining"
		const hours = Math.floor(total / 3600)
		const minutes = Math.floor((total % 3600) / 60)
		if (hours > 0)
			return hours + " h " + minutes + " min remaining"
		return minutes + " min remaining"
	}

	function limitText() {
		if (PowerProfiles.degradationReason === PerformanceDegradationReason.LapDetected)
			return "Limited while on your lap"
		if (PowerProfiles.degradationReason === PerformanceDegradationReason.HighTemperature)
			return "Limited while the laptop is hot"
		return ""
	}

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
