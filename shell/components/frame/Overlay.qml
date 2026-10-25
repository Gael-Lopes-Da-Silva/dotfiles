// Per-screen layer. Hot corners reveal the chips, and this file places every widget in the frame.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.components.cast
import qs.components.launcher
import qs.components.notifications
import qs.components.osd
import qs.components.radio
import qs.components.session
import qs.components.status
import qs.lib
import qs.services

PanelWindow {
	id: root

	required property var modelData

	screen: modelData
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore
	readonly property bool chrome: !NiriState.hidden

	onChromeChanged: {
		if (chrome)
			return
		statusWanted = false
		radioWanted = false
		sessionWanted = false
	}

	anchors.left: true
	anchors.right: true
	anchors.top: true
	anchors.bottom: true

	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.namespace: "shell"
	readonly property bool radioKeys: RadioState.menuPage === "wifi" && RadioState.pending !== null
	readonly property bool noticeKeys: NoticeState.replying && focusedHere
	WlrLayershell.keyboardFocus: launcherHere || radioKeys || noticeKeys ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

	readonly property bool focusedHere: {
		const _ = NiriState.revision
		if (NiriState.focusedOutput === "")
			return Quickshell.screens.length < 2
		return modelData.name === NiriState.focusedOutput
	}

	readonly property bool launcherHere: {
		if (!chrome || !NiriState.launcherOpen)
			return false
		if (NiriState.launcherOutput === "")
			return focusedHere
		return modelData.name === NiriState.launcherOutput
	}

	readonly property bool osdHere: {
		if (!NiriState.osdOpen || NiriState.launcherOpen)
			return false
		if (!chrome && NiriState.osdKind !== "usb")
			return false
		if (NiriState.osdKind === "usb" || NiriState.osdKind === "screen")
			return true
		return focusedHere
	}

	readonly property bool fullscreen: {
		const _ = NiriState.revision
		return NiriState.isFullscreen(modelData.name, modelData.width, modelData.height)
	}

	readonly property bool hotCorners: chrome && !fullscreen
	property real frameThickness: hotCorners ? Config.frame.thickness : 0
	property real frameRadius: hotCorners ? Config.frame.radius : 0

	onHotCornersChanged: {
		if (hotCorners)
			return
		statusWanted = false
		radioWanted = false
		sessionWanted = false
	}
	property bool statusWanted: false
	property real statusProgress: statusWanted ? 1 : 0
	readonly property string castMode: NiriState.castMode(modelData.name)
	property real castProgress: chrome && castMode !== "" ? 1 : 0
	readonly property real castInset: frameThickness - weld + noticeGap
	property bool radioWanted: false
	readonly property string radioPage: RadioState.menuOutput === modelData.name ? RadioState.menuPage : ""
	property string radioHold: "wifi"
	readonly property string radioShown: radioPage !== "" ? radioPage : radioHold
	property real radioProgress: radioWanted ? 1 : 0
	property real menuProgress: radioPage !== "" ? 1 : 0

	onRadioPageChanged: {
		if (radioPage !== "")
			radioHold = radioPage
	}
	property bool sessionWanted: false
	property bool sessionMenu: false
	property real sessionProgress: sessionWanted ? 1 : 0
	property real sessionMenuProgress: sessionMenu ? 1 : 0

	onSessionWantedChanged: {
		if (!sessionWanted)
			sessionMenu = false
	}
	readonly property string clockPage: PowerState.menuOutput === modelData.name ? PowerState.menuPage : ""
	property string clockHold: "time"
	property real clockMenuProgress: clockPage !== "" ? 1 : 0

	onClockPageChanged: {
		if (clockPage !== "")
			clockHold = clockPage
	}
	onStatusWantedChanged: {
		if (!statusWanted && PowerState.menuOutput === modelData.name)
			PowerState.closeMenu()
	}
	property real osdProgress: osdHere ? 1 : 0

	onRadioWantedChanged: {
		if (!radioWanted && RadioState.menuOutput === modelData.name)
			RadioState.closeMenu()
	}
	property real launcherProgress: launcherHere ? 1 : 0
	property real launcherFullH: launcherBody.item ? launcherBody.item.implicitHeight : 0
	property bool launcherAnimateH: false

	readonly property real weld: Math.min(Config.frame.weld, frameThickness)
	readonly property real noticeTop: {
		const underClock = statusClip.y + statusClip.height - weld
		const onFrame = frameThickness - weld
		return Math.max(onFrame, underClock)
	}
	readonly property real noticeGap: Theme.padding * (1 - Math.min(1, frameThickness / Math.max(1, Config.frame.thickness)))

	Behavior on frameThickness {
		NumberAnimation {
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	Behavior on frameRadius {
		NumberAnimation {
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	Behavior on statusProgress {
		NumberAnimation {
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	Behavior on castProgress {
		NumberAnimation {
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	Behavior on radioProgress {
		NumberAnimation {
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	Behavior on menuProgress {
		NumberAnimation {
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	Behavior on sessionProgress {
		NumberAnimation {
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	Behavior on sessionMenuProgress {
		NumberAnimation {
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	Behavior on clockMenuProgress {
		NumberAnimation {
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	Behavior on osdProgress {
		NumberAnimation {
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	Behavior on launcherProgress {
		NumberAnimation {
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	Behavior on launcherFullH {
		NumberAnimation {
			duration: root.launcherAnimateH ? Theme.motion : 0
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	function syncStatus() {
		if (!hotCorners) {
			statusWanted = false
			return
		}
		if (cornerHover.hovered || chipHover.hovered) {
			statusTimer.stop()
			statusWanted = true
		} else {
			statusTimer.restart()
		}
	}

	function syncRadio() {
		if (!hotCorners) {
			radioWanted = false
			return
		}
		if (radioCornerHover.hovered || radioHover.hovered) {
			radioTimer.stop()
			radioWanted = true
		} else {
			radioTimer.restart()
		}
	}

	function syncSession() {
		if (!hotCorners) {
			sessionWanted = false
			return
		}
		if (sessionCornerHover.hovered || sessionHover.hovered) {
			sessionTimer.stop()
			sessionWanted = true
		} else {
			sessionTimer.restart()
		}
	}

	function copyPickedColor(text) {
		let data
		try {
			data = JSON.parse(String(text || "").trim())
		} catch (e) {
			return
		}
		const rgb = data && data.rgb
		if (!rgb || rgb.length < 3)
			return
		let hex = "#"
		for (let i = 0; i < 3; i++) {
			const channel = Number(rgb[i])
			if (!Number.isFinite(channel))
				return
			const byte = Math.round(Math.min(1, Math.max(0, channel)) * 255)
			const pair = byte.toString(16)
			hex += pair.length < 2 ? "0" + pair : pair
		}
		Quickshell.execDetached(["wl-copy", "--type", "text/plain", hex])
	}

	Frame {
		anchors.fill: parent
		thickness: root.frameThickness
		radius: root.frameRadius
		smoothing: Config.frame.smoothing
		color: Theme.background
		panel0: Qt.vector4d(statusClip.x, statusClip.y, statusClip.width, statusClip.height)
		panel1: Qt.vector4d(osdClip.x, osdClip.y, osdClip.width, osdClip.height)
		panel2: Qt.vector4d(launcherClip.x, launcherClip.y, launcherClip.width, launcherClip.height)
		panel3: Qt.vector4d(castClip.x, castClip.y, castClip.width, castClip.height)
		panel4: Qt.vector4d(radioClip.x, radioClip.y, radioClip.width, radioClip.height)
		panel5: Qt.vector4d(noticeClip.x, noticeClip.y, noticeClip.width, noticeClip.height)
		panel6: Qt.vector4d(sessionClip.x, sessionClip.y, sessionClip.width, sessionClip.height)
		panelRadius: Qt.vector4d(Config.frame.radius, Config.frame.radius, Config.frame.radius, Config.frame.radius)
		panel4Radius: Config.frame.radius
		panel5Radius: Config.frame.radius
		panel6Radius: Config.frame.radius
	}

	MouseArea {
		id: dismiss
		anchors.fill: parent
		enabled: root.launcherHere
		z: 1
		onClicked: NiriState.closeLauncher()
	}

	Item {
		id: hotCorner
		z: 4
		anchors.top: parent.top
		anchors.right: parent.right
		width: root.hotCorners ? Config.frame.hotCorner : 0
		height: root.hotCorners ? Config.frame.hotCorner : 0

		HoverHandler {
			id: cornerHover
			enabled: root.hotCorners
			onHoveredChanged: root.syncStatus()
		}
	}

	Item {
		// Status chip and the menu under it: calendar, battery, or notices.
		id: statusClip
		z: 3
		width: Math.max(statusChip.implicitWidth, clockMenu.implicitWidth * root.clockMenuProgress) * root.statusProgress
		height: (statusChip.implicitHeight + clockMenu.implicitHeight * root.clockMenuProgress) * root.statusProgress
		x: root.width - root.frameThickness - width + root.weld
		y: root.frameThickness - root.weld
		clip: true
		visible: width > Config.frame.clipMin && height > Config.frame.clipMin

		Loader {
			id: statusChip
			anchors.top: parent.top
			anchors.right: parent.right
			active: root.statusWanted || root.statusProgress > 0 || root.clockPage !== "" || root.clockMenuProgress > 0
			asynchronous: false
			opacity: root.statusProgress > Config.frame.chipReveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}

			sourceComponent: Component {
				StatusChip {
					activePage: root.clockPage
					onTimeClicked: {
						root.statusWanted = true
						statusTimer.stop()
						PowerState.toggleMenu(root.modelData.name, "time")
					}
					onBatteryClicked: {
						root.statusWanted = true
						statusTimer.stop()
						PowerState.toggleMenu(root.modelData.name, "battery")
					}
					onNoticesClicked: {
						root.statusWanted = true
						statusTimer.stop()
						PowerState.toggleMenu(root.modelData.name, "notices")
					}
				}
			}
		}

		Loader {
			id: clockMenu
			anchors.top: statusChip.bottom
			anchors.right: parent.right
			active: root.clockPage !== "" || root.clockMenuProgress > 0
			asynchronous: false
			opacity: root.clockMenuProgress > Config.frame.menuReveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}

			sourceComponent: Component {
				StatusMenu {
					room: Math.min(root.height * Config.status.menuRatio, Math.max(Theme.rowHeight * 4, root.height - (root.frameThickness - root.weld) - statusChip.implicitHeight - Math.max(root.frameThickness, Theme.padding)))
					page: root.clockPage !== "" ? root.clockPage : root.clockHold
				}
			}
		}

		HoverHandler {
			id: chipHover
			onHoveredChanged: root.syncStatus()
		}
	}

	Item {
		// Toast stack on the focused screen.
		id: noticeClip
		z: 2
		visible: root.focusedHere && height > Config.frame.clipMin
		width: notices.implicitWidth
		height: root.focusedHere ? notices.implicitHeight : 0
		x: root.width - root.frameThickness - width + root.weld - root.noticeGap
		y: root.noticeTop + root.noticeGap

		Loader {
			id: notices
			active: root.focusedHere
			asynchronous: false
			onActiveChanged: {
				if (active)
					return
				NoticeState.paused = false
				NoticeState.replying = false
			}

			sourceComponent: Component {
				NoticePopup {
					maxHeight: Math.max(Config.notices.minHeight, root.height * Config.notices.popupRatio)
				}
			}
		}
	}

	Item {
		// Recording indicator.
		id: castClip
		z: 3
		width: castBody.implicitWidth * root.castProgress
		height: castBody.implicitHeight * root.castProgress
		x: root.castInset
		y: root.castInset
		clip: true
		visible: width > Config.frame.clipMin && height > Config.frame.clipMin

		Loader {
			id: castBody
			anchors.top: parent.top
			anchors.left: parent.left
			active: root.castMode !== "" || root.castProgress > 0
			asynchronous: false
			opacity: root.castProgress > Config.frame.chipReveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}

			sourceComponent: Component {
				CastIndicator { }
			}
		}
	}

	Item {
		// Volume, brightness, power, USB, and screen readout.
		id: osdClip
		z: 3
		width: osdBody.implicitWidth
		height: osdBody.implicitHeight * root.osdProgress
		x: (root.width - width) / 2
		y: root.height - root.frameThickness - height + root.weld
		clip: true
		visible: height > Config.frame.clipMin

		Loader {
			id: osdBody
			anchors.bottom: parent.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			active: root.osdHere || root.osdProgress > 0
			asynchronous: false
			opacity: root.osdProgress > Config.frame.chipReveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}

			sourceComponent: Component {
				Osd { }
			}
		}
	}

	Item {
		// Application search.
		id: launcherClip
		z: 4
		width: launcherBody.implicitWidth
		height: root.launcherFullH * root.launcherProgress
		x: (root.width - width) / 2
		y: root.height - root.frameThickness - height + root.weld - root.noticeGap
		clip: true
		visible: height > Config.frame.clipMin

		MouseArea {
			anchors.fill: parent
			enabled: root.launcherHere
			onClicked: mouse => mouse.accepted = true
		}

		Loader {
			id: launcherBody
			anchors.bottom: parent.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			active: root.launcherHere || root.launcherProgress > 0
			asynchronous: false
			opacity: root.launcherProgress > Config.frame.chipReveal ? 1 : 0
			onLoaded: Qt.callLater(() => {
				if (active)
					root.launcherAnimateH = true
			})
			onActiveChanged: {
				if (!active)
					root.launcherAnimateH = false
			}

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}

			sourceComponent: Component {
				Launcher {
					open: root.launcherHere
				}
			}
		}
	}

	Item {
		id: radioCorner
		z: 2
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		width: root.hotCorners ? Config.frame.hotCorner : 0
		height: root.hotCorners ? Config.frame.hotCorner : 0

		HoverHandler {
			id: radioCornerHover
			enabled: root.hotCorners
			onHoveredChanged: root.syncRadio()
		}
	}

	Item {
		// Wi-Fi, Bluetooth, audio, and microphone.
		id: radioClip
		z: 3
		width: Math.max(radioChip.implicitWidth, radioMenu.implicitWidth * root.menuProgress) * root.radioProgress
		height: (radioChip.implicitHeight + radioMenu.implicitHeight * root.menuProgress) * root.radioProgress
		x: root.frameThickness - root.weld
		y: root.height - root.frameThickness - height + root.weld
		clip: true
		visible: width > Config.frame.clipMin && height > Config.frame.clipMin

		Loader {
			id: radioMenu
			anchors.left: parent.left
			anchors.bottom: radioChip.top
			active: root.radioPage !== "" || root.menuProgress > 0
			asynchronous: false
			opacity: root.menuProgress > Config.frame.menuReveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}

			sourceComponent: Component {
				RadioMenu {
					page: root.radioShown
					live: root.radioPage !== ""
					room: {
						const audio = root.radioShown === "audio" || root.radioShown === "microphone"
						const ratio = audio ? Config.audio.menuRatio : Config.radio.menuRatio
						const chrome = root.height - (root.frameThickness - root.weld) - radioChip.implicitHeight - Math.max(root.frameThickness, Theme.padding)
						return Math.min(root.height * ratio, Math.max(Theme.rowHeight * 4, chrome))
					}
				}
			}
		}

		Loader {
			id: radioChip
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			active: root.radioWanted || root.radioProgress > 0 || root.radioPage !== "" || root.menuProgress > 0
			asynchronous: false
			opacity: root.radioProgress > Config.frame.chipReveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}

			sourceComponent: Component {
				RadioChip {
					openPage: root.menuProgress > 0 ? root.radioShown : RadioState.menuPage
					onPicked: page => {
						root.radioWanted = true
						radioTimer.stop()
						RadioState.toggleMenu(root.modelData.name, page)
					}
				}
			}
		}

		HoverHandler {
			id: radioHover
			onHoveredChanged: root.syncRadio()
		}
	}

	Item {
		id: sessionCorner
		z: 2
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		width: root.hotCorners ? Config.frame.hotCorner : 0
		height: root.hotCorners ? Config.frame.hotCorner : 0

		HoverHandler {
			id: sessionCornerHover
			enabled: root.hotCorners
			onHoveredChanged: root.syncSession()
		}
	}

	Item {
		// Color picker, screenshot, and power.
		id: sessionClip
		z: 3
		width: Math.max(sessionChip.implicitWidth, sessionMenuBody.implicitWidth * root.sessionMenuProgress) * root.sessionProgress
		height: (sessionChip.implicitHeight + sessionMenuBody.implicitHeight * root.sessionMenuProgress) * root.sessionProgress
		x: root.width - root.frameThickness - width + root.weld
		y: root.height - root.frameThickness - height + root.weld
		clip: true
		visible: width > Config.frame.clipMin && height > Config.frame.clipMin

		Loader {
			id: sessionMenuBody
			anchors.right: parent.right
			anchors.bottom: sessionChip.top
			active: root.sessionMenu || root.sessionMenuProgress > 0
			asynchronous: false
			opacity: root.sessionMenuProgress > Config.frame.menuReveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}

			sourceComponent: Component {
				SessionMenu {
					onChosen: {
						root.sessionMenu = false
						root.sessionWanted = false
					}
				}
			}
		}

		Loader {
			id: sessionChip
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			active: root.sessionWanted || root.sessionProgress > 0 || root.sessionMenu || root.sessionMenuProgress > 0
			asynchronous: false
			opacity: root.sessionProgress > Config.frame.chipReveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}

			sourceComponent: Component {
				SessionChip {
					powerOpen: root.sessionMenu
					onPowerClicked: {
						root.sessionWanted = true
						sessionTimer.stop()
						root.sessionMenu = !root.sessionMenu
					}
					onColorClicked: {
						colorPick.exec(Config.session.colorCommand)
						root.sessionMenu = false
						root.sessionWanted = false
					}
					onShotClicked: {
						Quickshell.execDetached(Config.session.screenshotCommand)
						root.sessionMenu = false
						root.sessionWanted = false
					}
				}
			}
		}

		HoverHandler {
			id: sessionHover
			onHoveredChanged: root.syncSession()
		}
	}

	Timer {
		id: statusTimer
		interval: Config.frame.hoverDelay
		onTriggered: {
			if (!cornerHover.hovered && !chipHover.hovered)
				root.statusWanted = false
		}
	}

	Timer {
		id: radioTimer
		interval: Config.frame.hoverDelay
		onTriggered: {
			if (!radioCornerHover.hovered && !radioHover.hovered)
				root.radioWanted = false
		}
	}

	Process {
		id: colorPick
		stdout: StdioCollector {
			onStreamFinished: root.copyPickedColor(this.text)
		}
	}

	Timer {
		id: sessionTimer
		interval: Config.frame.hoverDelay
		onTriggered: {
			if (!sessionCornerHover.hovered && !sessionHover.hovered)
				root.sessionWanted = false
		}
	}

	mask: Region {
		item: root.launcherHere ? dismiss : hotCorner

		Region {
			item: statusClip
		}
		Region {
			item: noticeClip
		}
		Region {
			item: radioCorner
		}
		Region {
			item: radioClip
		}
		Region {
			item: sessionCorner
		}
		Region {
			item: sessionClip
		}
	}
}
