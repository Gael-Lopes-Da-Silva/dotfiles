pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking

Singleton {
	id: root

	property int revision: 0
	property string menuOutput: ""
	property string menuPage: ""
	property var pending: null
	property string password: ""
	property real btRssi: -999

	readonly property var wifi: {
		const _ = revision
		const model = Networking.devices
		const list = model && model.values ? model.values : []
		for (let i = 0; i < list.length; i++) {
			if (list[i].type === DeviceType.Wifi)
				return list[i]
		}
		return null
	}

	readonly property var activeWifi: {
		const _ = revision
		const dev = wifi
		if (!dev || !dev.networks || !dev.networks.values)
			return null
		const list = dev.networks.values
		for (let i = 0; i < list.length; i++) {
			if (list[i].connected)
				return list[i]
		}
		return null
	}

	readonly property real wifiSignal: activeWifi ? activeWifi.signalStrength : 0

	readonly property var wifiList: {
		const _ = revision
		const dev = wifi
		if (!dev || !dev.networks || !dev.networks.values)
			return []
		const list = dev.networks.values.slice()
		list.sort((a, b) => {
			if (a.connected !== b.connected)
				return a.connected ? -1 : 1
			return (b.signalStrength || 0) - (a.signalStrength || 0)
		})
		const out = []
		for (let i = 0; i < list.length && out.length < 8; i++) {
			if (list[i].name)
				out.push(list[i])
		}
		return out
	}

	readonly property var bluetooth: Bluetooth.defaultAdapter

	readonly property var connectedBt: {
		const _ = revision
		const list = btDevices()
		for (let i = 0; i < list.length; i++) {
			if (list[i].connected)
				return list[i]
		}
		return null
	}

	readonly property bool btRssiKnown: btRssi > -200 && btRssi < 20
	readonly property real btQuality: {
		if (!connectedBt)
			return 0
		if (!btRssiKnown)
			return 1
		return Math.max(0, Math.min(1, (btRssi + 100) / 55))
	}

	readonly property var btList: {
		const _ = revision
		const list = btDevices().slice()
		list.sort((a, b) => {
			if (a.connected !== b.connected)
				return a.connected ? -1 : 1
			if (a.paired !== b.paired)
				return a.paired ? -1 : 1
			return deviceLabel(a).localeCompare(deviceLabel(b))
		})
		return list.slice(0, 8)
	}

	function btDevices() {
		const adapter = bluetooth
		if (!adapter || !adapter.devices || !adapter.devices.values)
			return []
		const list = adapter.devices.values
		const out = []
		for (let i = 0; i < list.length; i++) {
			if (deviceLabel(list[i]) !== "")
				out.push(list[i])
		}
		return out
	}

	function deviceLabel(device) {
		if (!device)
			return ""
		return device.name || device.deviceName || device.address || ""
	}

	function strengthGlyph(strength) {
		const bars = [0xF091F, 0xF0922, 0xF0925, 0xF0928]
		const idx = strength >= 0.75 ? 3 : strength >= 0.5 ? 2 : strength >= 0.25 ? 1 : 0
		return String.fromCodePoint(bars[idx])
	}

	function wifiGlyph() {
		if (!Networking.wifiEnabled)
			return String.fromCodePoint(0xF05AA)
		if (!activeWifi)
			return String.fromCodePoint(0xF092A)
		return strengthGlyph(wifiSignal)
	}

	function btGlyph() {
		const adapter = bluetooth
		if (!adapter || !adapter.enabled)
			return String.fromCodePoint(0xF00B2)
		if (!connectedBt)
			return String.fromCodePoint(0xF00AF)
		return String.fromCodePoint(0xF00B1)
	}

	function needsPsk(network) {
		if (!network || network.known)
			return false
		const security = network.security
		return security === WifiSecurityType.WpaPsk
			|| security === WifiSecurityType.Wpa2Psk
			|| security === WifiSecurityType.Sae
	}

	function secured(network) {
		if (!network)
			return false
		const security = network.security
		return security !== WifiSecurityType.Open && security !== WifiSecurityType.Owe
	}

	function toggleMenu(output, page) {
		if (menuOutput === output && menuPage === page) {
			menuPage = ""
			pending = null
			return
		}
		menuOutput = output
		menuPage = page
		pending = null
		password = ""
		revision++
	}

	function closeMenu() {
		menuPage = ""
		pending = null
		password = ""
	}

	function toggleWifi() {
		Networking.wifiEnabled = !Networking.wifiEnabled
		applyScan()
	}

	function toggleBluetooth() {
		const adapter = bluetooth
		if (!adapter)
			return
		adapter.enabled = !adapter.enabled
		applyScan()
	}

	function activateWifi(network) {
		if (!network)
			return
		if (network.connected) {
			network.disconnect()
			pending = null
			return
		}
		if (needsPsk(network)) {
			pending = network
			password = ""
			return
		}
		pending = null
		network.connect()
	}

	function submitPassword() {
		if (!pending)
			return
		pending.connectWithPsk(password)
		password = ""
		pending = null
	}

	function activateBt(device) {
		if (!device)
			return
		if (device.connected) {
			device.disconnect()
			return
		}
		if (device.paired)
			device.connect()
		else
			device.pair()
	}

	function applyScan() {
		const dev = wifi
		if (dev)
			dev.scannerEnabled = menuPage === "wifi" && Networking.wifiEnabled
		const adapter = bluetooth
		if (!adapter)
			return
		adapter.discovering = menuPage === "bluetooth" && adapter.enabled
	}

	onMenuPageChanged: applyScan()

	Timer {
		interval: root.menuPage !== "" ? 1500 : 4000
		repeat: true
		running: true
		triggeredOnStart: true
		onTriggered: root.revision++
	}

	Timer {
		interval: 2000
		repeat: true
		running: root.connectedBt !== null
		triggeredOnStart: true
		onTriggered: {
			const dev = root.connectedBt
			if (!dev || !dev.dbusPath)
				return
			rssi.exec(["busctl", "get-property", "org.bluez", dev.dbusPath, "org.bluez.Device1", "RSSI"])
		}
	}

	Process {
		id: rssi
		stdout: StdioCollector {
			onStreamFinished: {
				const match = String(this.text).match(/-?\d+/)
				root.btRssi = match ? parseInt(match[0], 10) : -999
			}
		}
	}

	onConnectedBtChanged: btRssi = -999
}
