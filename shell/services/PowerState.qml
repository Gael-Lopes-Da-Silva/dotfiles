pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.settings

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
			return Config.powerLap
		if (PowerProfiles.degradationReason === PerformanceDegradationReason.HighTemperature)
			return Config.powerHot
		return ""
	}

	function batteryGlyph() {
		if (!hasBattery)
			return ""
		const icons = plugged ? Config.batteryCharging : Config.batteryDischarging
		const steps = Config.batterySteps
		for (let i = 0; i < steps.length && i < icons.length; i++) {
			if (percent >= steps[i])
				return Config.icon(icons[i])
		}
		return Config.icon(icons[icons.length - 1])
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
		interval: Config.powerPrime
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
