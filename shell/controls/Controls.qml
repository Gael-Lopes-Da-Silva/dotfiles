pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import qs
import qs.common

Item {
	id: controls

	readonly property var wifiDevice: {
		const devices = Networking.devices.values
		for (let i = 0; i < devices.length; i++) {
			if (devices[i].type === DeviceType.Wifi)
				return devices[i]
		}
		return null
	}

	readonly property var adapter: Bluetooth.defaultAdapter
	readonly property bool open: surface.shown

	readonly property var networkList: {
		if (!wifiDevice)
			return []
		const values = wifiDevice.networks.values
		const list = []
		for (let i = 0; i < values.length; i++)
			list.push(values[i])
		list.sort((a, b) => b.signalStrength - a.signalStrength)
		return list
	}

	readonly property string currentWifi: {
		for (let i = 0; i < networkList.length; i++) {
			if (networkList[i].connected)
				return networkList[i].name
		}
		return ""
	}

	readonly property var bluetoothDevices: {
		if (!adapter)
			return []
		const values = adapter.devices.values
		const list = []
		for (let i = 0; i < values.length; i++) {
			const device = values[i]
			if (device.blocked)
				continue
			if (device.paired || (open && adapter.discovering))
				list.push(device)
		}
		list.sort((a, b) => Number(b.connected) - Number(a.connected) || Number(b.paired) - Number(a.paired) || (a.name || "").localeCompare(b.name || ""))
		return list
	}

	function syncRadios() {
		if (wifiDevice)
			wifiDevice.scannerEnabled = open
		if (adapter)
			adapter.discovering = open && adapter.enabled
	}

	function toggle() {
		if (surface.shown)
			surface.dismiss()
		else
			surface.summon()
	}

	function canConnect(network) {
		return network.known || network.security === WifiSecurityType.Open || network.security === WifiSecurityType.Owe
	}

	onOpenChanged: syncRadios()
	onWifiDeviceChanged: syncRadios()
	onAdapterChanged: syncRadios()

	Connections {
		target: controls.adapter
		function onEnabledChanged() {
			controls.syncRadios()
		}
	}

	Surface {
		id: surface
		lifetime: "session"
		edge: "center"
		wantsKeyboard: true
		namespace: "controls"

		content: Rectangle {
			implicitWidth: 400
			implicitHeight: column.implicitHeight + Theme.padding * 2
			radius: Theme.radius
			color: Theme.background
			border.color: Theme.border
			border.width: 1

			Column {
				id: column
				x: Theme.padding
				y: Theme.padding
				width: 400 - Theme.padding * 2
				spacing: Theme.gap

				Row {
					width: parent.width
					spacing: Theme.gap

					Text {
						width: parent.width - radio.implicitWidth - Theme.gap
						anchors.verticalCenter: parent.verticalCenter
						text: "Wi-Fi"
						color: Theme.foreground
						font.family: Theme.fontFamily
						font.pixelSize: Theme.fontSize
					}

					Button {
						id: radio
						anchors.verticalCenter: parent.verticalCenter
						text: Networking.wifiEnabled ? "On" : "Off"
						onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
					}
				}

				Text {
					width: parent.width
					text: !Networking.wifiEnabled ? "Off" : controls.currentWifi || "Not connected"
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
					elide: Text.ElideRight
				}

				Flickable {
					width: parent.width
					height: Math.min(networks.implicitHeight, 220)
					contentHeight: networks.implicitHeight
					clip: true
					visible: Networking.wifiEnabled && controls.networkList.length > 0

					Column {
						id: networks
						width: parent.width
						spacing: 4

						Repeater {
							model: controls.networkList

							Row {
								id: networkRow
								required property var modelData
								width: parent.width
								spacing: 8

								Text {
									width: parent.width - networkAction.implicitWidth - 8
									anchors.verticalCenter: parent.verticalCenter
									text: networkRow.modelData.name + "   " + networkRow.modelData.signalStrength + "%"
									color: networkRow.modelData.connected ? Theme.foreground : Theme.muted
									font.family: Theme.fontFamily
									font.pixelSize: Theme.fontSize
									elide: Text.ElideRight
								}

								Button {
									id: networkAction
									anchors.verticalCenter: parent.verticalCenter
									visible: networkRow.modelData.connected || controls.canConnect(networkRow.modelData)
									text: networkRow.modelData.connected ? "Disconnect" : "Connect"
									onClicked: {
										if (networkRow.modelData.connected)
											networkRow.modelData.disconnect()
										else
											networkRow.modelData.connect()
									}
								}
							}
						}
					}
				}

				Rectangle {
					width: parent.width
					height: 1
					color: Theme.border
				}

				Row {
					width: parent.width
					spacing: Theme.gap

					Text {
						width: parent.width - power.implicitWidth - Theme.gap
						anchors.verticalCenter: parent.verticalCenter
						text: "Bluetooth"
						color: Theme.foreground
						font.family: Theme.fontFamily
						font.pixelSize: Theme.fontSize
					}

					Button {
						id: power
						anchors.verticalCenter: parent.verticalCenter
						enabled: controls.adapter !== null
						text: controls.adapter && controls.adapter.enabled ? "On" : "Off"
						onClicked: {
							if (controls.adapter)
								controls.adapter.enabled = !controls.adapter.enabled
						}
					}
				}

				Text {
					visible: !controls.adapter
					text: "No adapter"
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
				}

				Flickable {
					width: parent.width
					height: Math.min(devices.implicitHeight, 220)
					contentHeight: devices.implicitHeight
					clip: true
					visible: controls.adapter && controls.adapter.enabled && controls.bluetoothDevices.length > 0

					Column {
						id: devices
						width: parent.width
						spacing: 4

						Repeater {
							model: controls.bluetoothDevices

							Row {
								id: deviceRow
								required property var modelData
								width: parent.width
								spacing: 8

								Text {
									width: parent.width - deviceAction.implicitWidth - 8
									anchors.verticalCenter: parent.verticalCenter
									text: deviceRow.modelData.name || deviceRow.modelData.address
									color: deviceRow.modelData.connected ? Theme.foreground : Theme.muted
									font.family: Theme.fontFamily
									font.pixelSize: Theme.fontSize
									elide: Text.ElideRight
								}

								Button {
									id: deviceAction
									anchors.verticalCenter: parent.verticalCenter
									text: deviceRow.modelData.connected ? "Disconnect" : deviceRow.modelData.paired ? "Connect" : deviceRow.modelData.pairing ? "Pairing" : "Pair"
									onClicked: {
										const device = deviceRow.modelData
										if (device.connected)
											device.disconnect()
										else if (device.paired)
											device.connect()
										else if (!device.pairing)
											device.pair()
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
