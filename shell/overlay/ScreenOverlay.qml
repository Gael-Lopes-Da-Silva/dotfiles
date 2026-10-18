import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.settings
import qs.cast
import qs.launcher
import qs.notices
import qs.osd
import qs.radio
import qs.services
import qs.session
import qs.status

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

	property real frameThickness: chrome && !fullscreen ? Theme.frame : 0
	property real frameRadius: chrome && !fullscreen ? Theme.screenRadius : 0
	property bool statusWanted: false
	property real statusProgress: statusWanted ? 1 : 0
	readonly property string castMode: NiriState.castMode(modelData.name)
	property string castHold: "recording"
	readonly property string castLabel: castMode !== "" ? castMode : castHold
	property real castProgress: chrome && castMode !== "" ? 1 : 0

	onCastModeChanged: {
		if (castMode !== "")
			castHold = castMode
	}
	property bool radioWanted: false
	readonly property string radioPage: RadioState.menuOutput === modelData.name ? RadioState.menuPage : ""
	property real radioProgress: radioWanted ? 1 : 0
	property real menuProgress: radioPage !== "" ? 1 : 0
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
	property real launcherFullH: launcherBody.implicitHeight

	readonly property real weld: Math.min(Theme.weld, frameThickness)
	readonly property real noticeTop: {
		const underClock = statusClip.y + statusClip.height - weld
		const onFrame = frameThickness - weld
		return Math.max(onFrame, underClock)
	}
	readonly property real noticeGap: Theme.padding * (1 - Math.min(1, frameThickness / Math.max(1, Theme.frame)))

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
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	function syncStatus() {
		if (!chrome) {
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
		if (!chrome) {
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
		if (!chrome) {
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

	BlobField {
		anchors.fill: parent
		thickness: root.frameThickness
		radius: root.frameRadius
		smoothing: Theme.smoothing
		color: Theme.background
		panel0: Qt.vector4d(statusClip.x, statusClip.y, statusClip.width, statusClip.height)
		panel1: Qt.vector4d(osdClip.x, osdClip.y, osdClip.width, osdClip.height)
		panel2: Qt.vector4d(launcherClip.x, launcherClip.y, launcherClip.width, launcherClip.height)
		panel3: Qt.vector4d(castClip.x, castClip.y, castClip.width, castClip.height)
		panel4: Qt.vector4d(radioClip.x, radioClip.y, radioClip.width, radioClip.height)
		panel5: Qt.vector4d(noticeClip.x, noticeClip.y, noticeClip.width, noticeClip.height)
		panel6: Qt.vector4d(sessionClip.x, sessionClip.y, sessionClip.width, sessionClip.height)
		panelRadius: Qt.vector4d(Theme.screenRadius, Theme.screenRadius, Theme.screenRadius, Theme.screenRadius)
		panel4Radius: Theme.screenRadius
		panel5Radius: Theme.screenRadius
		panel6Radius: Theme.screenRadius
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
		width: root.chrome ? Config.hotCorner : 0
		height: root.chrome ? Config.hotCorner : 0

		HoverHandler {
			id: cornerHover
			onHoveredChanged: root.syncStatus()
		}
	}

	Item {
		id: statusClip
		z: 3
		width: Math.max(statusChip.implicitWidth, clockMenu.implicitWidth * root.clockMenuProgress) * root.statusProgress
		height: (statusChip.implicitHeight + clockMenu.implicitHeight * root.clockMenuProgress) * root.statusProgress
		x: root.width - root.frameThickness - width + root.weld
		y: root.frameThickness - root.weld
		clip: true
		visible: width > Config.clipMin && height > Config.clipMin

		StatusChip {
			id: statusChip
			anchors.top: parent.top
			anchors.right: parent.right
			activePage: root.clockPage
			opacity: root.statusProgress > Config.reveal ? 1 : 0
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

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}
		}

		ClockMenu {
			id: clockMenu
			anchors.top: statusChip.bottom
			anchors.right: parent.right
			room: Math.min(root.height * Config.noticeCenterRatio, Math.max(Theme.rowHeight * 4, root.height - (root.frameThickness - root.weld) - statusChip.implicitHeight - Math.max(root.frameThickness, Theme.padding)))
			page: root.clockPage !== "" ? root.clockPage : root.clockHold
			opacity: root.clockMenuProgress > Config.menuReveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}
		}

		HoverHandler {
			id: chipHover
			onHoveredChanged: root.syncStatus()
		}
	}

	Item {
		id: noticeClip
		z: 2
		visible: root.focusedHere && height > Config.clipMin
		width: notices.implicitWidth
		height: root.focusedHere ? notices.implicitHeight : 0
		x: root.width - root.frameThickness - width + root.weld - root.noticeGap
		y: root.noticeTop + root.noticeGap

		Notifications {
			id: notices
			maxHeight: Math.max(Config.noticeMinHeight, root.height * Config.noticeHeightRatio)
		}
	}

	Item {
		id: castClip
		z: 3
		width: castBody.implicitWidth * root.castProgress
		height: castBody.implicitHeight * root.castProgress
		x: root.frameThickness - root.weld
		y: root.frameThickness - root.weld
		clip: true
		visible: width > Config.clipMin && height > Config.clipMin

		CastIndicator {
			id: castBody
			mode: root.castLabel
			output: root.modelData.name
			anchors.top: parent.top
			anchors.left: parent.left
			opacity: root.castProgress > Config.reveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}
		}
	}

	Item {
		id: osdClip
		z: 3
		width: osdBody.implicitWidth
		height: osdBody.implicitHeight * root.osdProgress
		x: (root.width - width) / 2
		y: root.height - root.frameThickness - height + root.weld
		clip: true
		visible: height > Config.clipMin

		Osd {
			id: osdBody
			anchors.bottom: parent.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			opacity: root.osdProgress > Config.reveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}
		}
	}

	Item {
		id: launcherClip
		z: 4
		width: launcherBody.implicitWidth
		height: root.launcherFullH * root.launcherProgress
		x: (root.width - width) / 2
		y: root.height - root.frameThickness - height + root.weld
		clip: true
		visible: height > Config.clipMin

		MouseArea {
			anchors.fill: parent
			enabled: root.launcherHere
			onClicked: mouse => mouse.accepted = true
		}

		Launcher {
			id: launcherBody
			anchors.bottom: parent.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			open: root.launcherHere
			opacity: root.launcherProgress > Config.reveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}
		}
	}

	Item {
		id: radioCorner
		z: 2
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		width: root.chrome ? Config.hotCorner : 0
		height: root.chrome ? Config.hotCorner : 0

		HoverHandler {
			id: radioCornerHover
			onHoveredChanged: root.syncRadio()
		}
	}

	Item {
		id: radioClip
		z: 3
		width: Math.max(radioChip.implicitWidth, radioMenu.implicitWidth * root.menuProgress) * root.radioProgress
		height: (radioChip.implicitHeight + radioMenu.implicitHeight * root.menuProgress) * root.radioProgress
		x: root.frameThickness - root.weld
		y: root.height - root.frameThickness - height + root.weld
		clip: true
		visible: width > Config.clipMin && height > Config.clipMin

		RadioMenu {
			id: radioMenu
			anchors.left: parent.left
			anchors.bottom: radioChip.top
			opacity: root.menuProgress > Config.menuReveal ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}
		}

		RadioChip {
			id: radioChip
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			opacity: root.radioProgress > Config.reveal ? 1 : 0
			onPicked: page => {
				root.radioWanted = true
				radioTimer.stop()
				RadioState.toggleMenu(root.modelData.name, page)
			}

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
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
		width: root.chrome ? Config.hotCorner : 0
		height: root.chrome ? Config.hotCorner : 0

		HoverHandler {
			id: sessionCornerHover
			onHoveredChanged: root.syncSession()
		}
	}

	Item {
		id: sessionClip
		z: 3
		width: Math.max(sessionChip.implicitWidth, sessionMenuBody.implicitWidth * root.sessionMenuProgress) * root.sessionProgress
		height: (sessionChip.implicitHeight + sessionMenuBody.implicitHeight * root.sessionMenuProgress) * root.sessionProgress
		x: root.width - root.frameThickness - width + root.weld
		y: root.height - root.frameThickness - height + root.weld
		clip: true
		visible: width > Config.clipMin && height > Config.clipMin

		SessionMenu {
			id: sessionMenuBody
			anchors.right: parent.right
			anchors.bottom: sessionChip.top
			opacity: root.sessionMenuProgress > Config.menuReveal ? 1 : 0
			onChosen: {
				root.sessionMenu = false
				root.sessionWanted = false
			}

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}
		}

		SessionChip {
			id: sessionChip
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			powerOpen: root.sessionMenu
			opacity: root.sessionProgress > Config.reveal ? 1 : 0
			onPowerClicked: {
				root.sessionWanted = true
				sessionTimer.stop()
				root.sessionMenu = !root.sessionMenu
			}
			onShotClicked: {
				Quickshell.execDetached(Config.screenshotCommand)
				root.sessionMenu = false
				root.sessionWanted = false
			}

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}
		}

		HoverHandler {
			id: sessionHover
			onHoveredChanged: root.syncSession()
		}
	}

	Timer {
		id: statusTimer
		interval: Config.hoverDelay
		onTriggered: {
			if (!cornerHover.hovered && !chipHover.hovered)
				root.statusWanted = false
		}
	}

	Timer {
		id: radioTimer
		interval: Config.hoverDelay
		onTriggered: {
			if (!radioCornerHover.hovered && !radioHover.hovered)
				root.radioWanted = false
		}
	}

	Timer {
		id: sessionTimer
		interval: Config.hoverDelay
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
