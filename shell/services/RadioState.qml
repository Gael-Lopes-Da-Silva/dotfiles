// Wi-Fi and Bluetooth lists, signal glyphs, and which radio page is open.

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import qs.lib

Singleton {
	id: root

	property int revision: 0
	property bool wifiWarm: false
	property bool btWarm: false
	property string menuOutput: ""
	property string menuPage: ""
	property var pending: null
	property string password: ""
	property real btRssi: Config.radio.rssiUnknown
	property bool btBatteryLowSeen: false
	property string btBatteryLowDevice: ""

	readonly property bool wifiReady: !Networking.wifiEnabled || wifiWarm
	readonly property bool btReady: !(bluetooth && bluetooth.enabled) || btWarm

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

	readonly property var wired: {
		const _ = revision
		const model = Networking.devices
		const list = model && model.values ? model.values : []
		for (let i = 0; i < list.length; i++) {
			const dev = list[i]
			if (dev.type === DeviceType.Wired && dev.connected)
				return dev
		}
		return null
	}

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
		for (let i = 0; i < list.length && out.length < Config.radio.networkLimit; i++) {
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

	readonly property bool btRssiKnown: btRssi > Config.radio.rssiMin && btRssi < Config.radio.rssiMax
	readonly property real btQuality: {
		if (!connectedBt)
			return 0
		if (!btRssiKnown)
			return 1
		return Math.max(0, Math.min(1, (btRssi - Config.radio.rssiFloor) / Config.radio.rssiSpan))
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
		return list.slice(0, Config.radio.deviceLimit)
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

	function checkBtBattery() {
		const devices = btDevices()
		const lowPercent = Config.battery.btBatteryLowPercent
		let foundLow = false
		let lowestDevice = ""
		let lowestLevel = 100

		for (let i = 0; i < devices.length; i++) {
			const dev = devices[i]
			if (dev.connected && dev.batteryAvailable) {
				const level = dev.battery * 100
				if (level <= lowPercent && level < lowestLevel) {
					foundLow = true
					lowestDevice = deviceLabel(dev)
					lowestLevel = level
				}
			}
		}

		if (foundLow) {
			if (btBatteryLowDevice !== lowestDevice || !btBatteryLowSeen) {
				reportBtLow(lowestDevice, Math.round(lowestLevel))
			}
			btBatteryLowDevice = lowestDevice
			btBatteryLowSeen = true
		} else if (btBatteryLowSeen) {
			btBatteryLowSeen = false
			btBatteryLowDevice = ""
		}
	}

	function reportBtLow(deviceName, percent) {
		NoticeState.powerNotice(
			"Bluetooth battery low",
			deviceName + " at " + percent + "%",
			true
		)
	}

	function strengthGlyph(strength) {
		const bars = Config.radio.wifiIcons
		const idx = strength >= 0.75 ? 3 : strength >= 0.5 ? 2 : strength >= 0.25 ? 1 : 0
		return Config.icon(bars[idx])
	}

	function wifiGlyph() {
		if (!Networking.wifiEnabled)
			return Config.icon(Config.radio.wifiOffIcon)
		if (!activeWifi)
			return Config.icon(Config.radio.wifiIdleIcon)
		return strengthGlyph(wifiSignal)
	}

	function linkGlyph() {
		if (wired)
			return Config.icon(Config.radio.ethernetIcon)
		return wifiGlyph()
	}

	function ethernetName() {
		const dev = wired
		if (!dev)
			return ""
		const net = dev.network
		const profile = net && net.name
		if (profile && profile !== dev.name)
			return profile
		return "Ethernet"
	}

	function linkRate(speed) {
		if (speed >= 1000) {
			const gigs = speed / 1000
			const text = Number.isInteger(gigs) ? String(gigs) : gigs.toFixed(1)
			return text + " Gb/s"
		}
		return speed + " Mb/s"
	}

	function ethernetFacts() {
		const dev = wired
		if (!dev)
			return ""
		const parts = []
		if (dev.name)
			parts.push(dev.name)
		const speed = Number(dev.linkSpeed) || 0
		if (speed > 0)
			parts.push(linkRate(speed))
		if (dev.address)
			parts.push(dev.address)
		return parts.join("  ·  ")
	}

	function btGlyph() {
		const adapter = bluetooth
		if (!adapter || !adapter.enabled)
			return Config.icon(Config.radio.bluetoothOffIcon)
		if (!connectedBt)
			return Config.icon(Config.radio.bluetoothIdleIcon)
		return Config.icon(Config.radio.bluetoothOnIcon)
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
			beginClose()
			return
		}
		closeHold.stop()
		menuOutput = output
		menuPage = page
		pending = null
		password = ""
		revision++
	}

	function closeMenu() {
		beginClose()
	}

	function beginClose() {
		if (menuPage === "")
			return
		menuPage = ""
		closeHold.restart()
	}

	// Scanning stops and the password row clears once the close animation is done.
	function releaseClose() {
		if (menuPage !== "")
			return
		pending = null
		password = ""
		applyScan()
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
			dev.scannerEnabled = Networking.wifiEnabled && (menuPage === "wifi" || !wifiWarm)
		const adapter = bluetooth
		if (!adapter)
			return
		adapter.discovering = adapter.enabled && (menuPage === "bluetooth" || !btWarm)
	}

	function touch() {
		touchTimer.restart()
	}

	onMenuPageChanged: {
		if (menuPage === "")
			return
		closeHold.stop()
		applyScan()
	}

	Timer {
		id: closeHold
		interval: Theme.motion
		onTriggered: root.releaseClose()
	}
	onWifiChanged: applyScan()
	onBluetoothChanged: {
		applyScan()
		touch()
	}

	Timer {
		id: touchTimer
		interval: 32
		onTriggered: root.revision++
	}

	Timer {
		interval: Config.radio.warmTick
		repeat: true
		running: !root.wifiWarm || !root.btWarm
		triggeredOnStart: true
		onTriggered: root.revision++
	}

	Timer {
		interval: Config.radio.warmup
		running: !root.wifiWarm || !root.btWarm
		onTriggered: {
			root.wifiWarm = true
			root.btWarm = true
			root.applyScan()
			root.revision++
		}
	}

	Timer {
		interval: Config.radio.refreshIdle
		repeat: true
		running: root.wifiWarm && root.btWarm && root.menuPage === ""
		onTriggered: root.revision++
	}

	Timer {
		interval: Config.radio.refreshOpen
		repeat: true
		running: root.menuPage !== ""
		triggeredOnStart: true
		onTriggered: root.revision++
	}

	Connections {
		target: Networking
		function onWifiEnabledChanged() {
			root.touch()
			root.applyScan()
		}
	}

	property var deviceWires: ({})
	property var btWires: ({})

	function remember(pool, object, wire) {
		if (!object || !wire)
			return
		pool[String(object)] = wire
	}

	function forget(pool, object) {
		if (!object)
			return
		const id = String(object)
		const wires = pool[id]
		if (!wires)
			return
		for (let i = 0; i < wires.length; i++) {
			if (wires[i])
				wires[i].destroy()
		}
		delete pool[id]
	}

	function bindDevice(dev) {
		if (!dev || !deviceWatch || root.deviceWires[String(dev)])
			return
		const wires = []
		wires.push(deviceWatch.createObject(root, { target: dev }))
		if (dev.networks)
			wires.push(networkWatch.createObject(root, { target: dev.networks }))
		root.remember(root.deviceWires, dev, wires)
	}

	function bindBt(dev) {
		if (!dev || !btWatch || root.btWires[String(dev)])
			return
		root.remember(root.btWires, dev, [btWatch.createObject(root, { target: dev })])
	}

	Component {
		id: deviceWatch
		Connections {
			function onConnectedChanged() { root.touch() }
			function onNameChanged() { root.touch() }
			function onAddressChanged() { root.touch() }
		}
	}

	Component {
		id: networkWatch
		Connections {
			function onObjectInsertedPost(object, index) { root.touch() }
			function onObjectRemovedPost(object, index) { root.touch() }
		}
	}

	Component {
		id: btWatch
		Connections {
			function onConnectedChanged() { root.touch(); root.checkBtBattery() }
			function onPairedChanged() { root.touch() }
			function onNameChanged() { root.touch() }
			function onDeviceNameChanged() { root.touch() }
			function onBatteryChanged() { root.touch(); root.checkBtBattery() }
			function onBatteryAvailableChanged() { root.touch(); root.checkBtBattery() }
		}
	}

	Connections {
		target: Networking.devices
		function onObjectInsertedPost(object, index) {
			root.bindDevice(object)
			root.touch()
		}
		function onObjectRemovedPre(object, index) { root.forget(root.deviceWires, object) }
		function onObjectRemovedPost(object, index) { root.touch() }
	}

	Connections {
		target: Bluetooth
		function onDefaultAdapterChanged() {
			root.touch()
			root.applyScan()
		}
	}

	Connections {
		target: Bluetooth.devices
		function onObjectInsertedPost(object, index) {
			root.bindBt(object)
			root.touch()
			root.checkBtBattery()
		}
		function onObjectRemovedPre(object, index) { root.forget(root.btWires, object) }
		function onObjectRemovedPost(object, index) { root.touch()
			root.checkBtBattery()
		}
	}

	Connections {
		target: root.bluetooth
		function onEnabledChanged() {
			root.touch()
			root.applyScan()
		}
	}

	Component.onCompleted: {
		const devices = Networking.devices.values
		for (let i = 0; i < devices.length; i++)
			bindDevice(devices[i])
		const found = Bluetooth.devices.values
		for (let i = 0; i < found.length; i++)
			bindBt(found[i])
		applyScan()
	}

	Timer {
		interval: Config.radio.rssiPoll
		repeat: true
		running: root.connectedBt !== null
		triggeredOnStart: true
		onTriggered: {
			const dev = root.connectedBt
			if (!dev || !dev.dbusPath)
				return
			rssi.exec(["busctl", "get-property", "org.bluez", dev.dbusPath, "org.bluez.Device1", "RSSI"])
			root.checkBtBattery()
		}
	}

	Process {
		id: rssi
		stdout: StdioCollector {
			onStreamFinished: {
				const match = String(this.text).match(/-?\d+/)
				root.btRssi = match ? parseInt(match[0], 10) : Config.radio.rssiUnknown
			}
		}
	}

	onConnectedBtChanged: {
		btRssi = Config.radio.rssiUnknown
		root.checkBtBattery()
	}
}
