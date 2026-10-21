// Battery, charger, and power profiles.

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.settings

Singleton {
	id: root

	property bool primed: false
	property bool pluggedSeen: false
	property int percentSeen: 0
	property bool lowSeen: false
	property bool fullSeen: false

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
			return Config.battery.lapLimit
		if (PowerProfiles.degradationReason === PerformanceDegradationReason.HighTemperature)
			return Config.battery.hotLimit
		return ""
	}

	function batteryGlyph() {
		if (!hasBattery)
			return ""
		const icons = plugged ? Config.battery.chargingIcons : Config.battery.dischargingIcons
		const steps = Config.battery.steps
		for (let i = 0; i < steps.length && i < icons.length; i++) {
			if (percent >= steps[i])
				return Config.icon(icons[i])
		}
		return Config.icon(icons[icons.length - 1])
	}

	function capture() {
		pluggedSeen = plugged
		percentSeen = percent
		lowSeen = hasBattery && !plugged && percent <= Config.battery.lowPercent
		fullSeen = hasBattery && plugged && percent >= 100
	}

	function reportLow() {
		NoticeState.powerNotice(Config.battery.lowTitle, percent + Config.battery.remaining, true)
	}

	// One notice each time charge falls to the low mark, and one when a charge reaches full.
	function note() {
		if (!primed || !hasBattery)
			return
		const wasPlugged = pluggedSeen
		if (plugged !== pluggedSeen) {
			pluggedSeen = plugged
			NiriState.showOsd("power")
		}
		const low = !plugged && percent <= Config.battery.lowPercent
		const wasLow = lowSeen
		lowSeen = low
		if (low && !wasLow)
			reportLow()
		const reachedFull = plugged && percent >= 100 && !fullSeen && wasPlugged && percentSeen < 100
		if (plugged && percent >= 100)
			fullSeen = true
		else if (!plugged)
			fullSeen = false
		percentSeen = percent
		if (reachedFull)
			NoticeState.powerNotice(Config.battery.full, "", false)
	}

	onPluggedChanged: note()
	onPercentChanged: note()

	Timer {
		id: arm
		interval: Config.battery.prime
		onTriggered: {
			root.capture()
			root.primed = true
			if (root.lowSeen)
				root.reportLow()
		}
	}

	Component.onCompleted: arm.restart()
	onHasBatteryChanged: {
		if (!primed) {
			arm.restart()
			return
		}
		const wasLow = lowSeen
		capture()
		if (lowSeen && !wasLow)
			reportLow()
	}
}
