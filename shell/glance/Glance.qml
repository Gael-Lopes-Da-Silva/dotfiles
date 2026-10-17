pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs
import qs.common

Item {
	id: glance

	readonly property var battery: UPower.displayDevice
	readonly property bool hasBattery: battery && battery.ready && battery.isLaptopBattery && battery.isPresent

	function stateText(state) {
		switch (state) {
		case UPowerDeviceState.Charging:
		case UPowerDeviceState.PendingCharge:
			return "Charging"
		case UPowerDeviceState.Discharging:
		case UPowerDeviceState.PendingDischarge:
			return "Discharging"
		case UPowerDeviceState.FullyCharged:
			return "Full"
		case UPowerDeviceState.Empty:
			return "Empty"
		default:
			return ""
		}
	}

	function roughTime(seconds) {
		if (!seconds || seconds < 60)
			return ""
		const hours = Math.floor(seconds / 3600)
		const minutes = Math.round((seconds % 3600) / 60)
		if (hours <= 0)
			return minutes + " min"
		return hours + " h " + minutes + " min"
	}

	readonly property string batteryText: {
		if (!hasBattery)
			return ""
		const percent = Math.round(battery.percentage) + "%"
		const state = stateText(battery.state)
		const remaining = battery.state === UPowerDeviceState.Discharging ? roughTime(battery.timeToEmpty) : ""
		return [percent, state, remaining].filter(part => part.length > 0).join("   ·   ")
	}

	function show() {
		surface.summon()
	}

	Surface {
		id: surface
		lifetime: "transient"
		edge: "center"
		namespace: "glance"
		timeout: Theme.glanceTimeout

		content: Rectangle {
			implicitWidth: Math.max(time.implicitWidth, batteryLabel.implicitWidth) + Theme.padding * 2
			implicitHeight: column.implicitHeight + Theme.padding * 2
			radius: Theme.radius
			color: Theme.background
			border.color: Theme.border
			border.width: 1

			Column {
				id: column
				anchors.centerIn: parent
				spacing: Theme.gap

				Text {
					id: time
					anchors.horizontalCenter: parent.horizontalCenter
					text: Time.text
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: 22
				}

				Text {
					id: batteryLabel
					anchors.horizontalCenter: parent.horizontalCenter
					visible: glance.hasBattery
					text: glance.batteryText
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
				}
			}
		}
	}
}
