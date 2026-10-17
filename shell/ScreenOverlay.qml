import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
	id: root

	required property var modelData

	screen: modelData
	color: "transparent"
	exclusionMode: ExclusionMode.Ignore

	anchors.left: true
	anchors.right: true
	anchors.top: true
	anchors.bottom: true

	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.namespace: "shell"
	WlrLayershell.keyboardFocus: launcherHere ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

	readonly property bool focusedHere: {
		const _ = NiriState.revision
		if (NiriState.focusedOutput === "")
			return Quickshell.screens.length < 2
		return modelData.name === NiriState.focusedOutput
	}

	readonly property bool launcherHere: {
		if (!NiriState.launcherOpen)
			return false
		if (NiriState.launcherOutput === "")
			return focusedHere
		return modelData.name === NiriState.launcherOutput
	}

	readonly property bool osdHere: NiriState.osdOpen && !NiriState.launcherOpen && focusedHere

	readonly property bool fullscreen: {
		const _ = NiriState.revision
		return NiriState.isFullscreen(modelData.name, modelData.width, modelData.height)
	}

	property real frameThickness: fullscreen ? 0 : Theme.frame
	property real frameRadius: fullscreen ? 0 : Theme.screenRadius
	property bool statusWanted: false
	property real statusProgress: statusWanted ? 1 : 0
	property real osdProgress: osdHere ? 1 : 0
	property real launcherProgress: launcherHere ? 1 : 0
	property real launcherFullH: launcherBody.implicitHeight

	readonly property real weld: Math.min(Theme.weld, frameThickness)

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
		if (cornerHover.hovered || chipHover.hovered) {
			statusTimer.stop()
			statusWanted = true
		} else {
			statusTimer.restart()
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
		panelRadius: Qt.vector4d(Theme.screenRadius, Theme.screenRadius, Theme.screenRadius, 0)
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
		z: 2
		anchors.top: parent.top
		anchors.right: parent.right
		width: 16
		height: 16

		HoverHandler {
			id: cornerHover
			onHoveredChanged: root.syncStatus()
		}
	}

	Item {
		id: statusClip
		z: 3
		width: statusChip.implicitWidth * root.statusProgress
		height: statusChip.implicitHeight * root.statusProgress
		x: root.width - root.frameThickness - width + root.weld
		y: root.frameThickness - root.weld
		clip: true
		visible: width > 2 && height > 2

		StatusChip {
			id: statusChip
			anchors.top: parent.top
			anchors.right: parent.right
			opacity: root.statusProgress > 0.72 ? 1 : 0

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
		id: osdClip
		z: 3
		width: osdBody.implicitWidth
		height: osdBody.implicitHeight * root.osdProgress
		x: (root.width - width) / 2
		y: root.height - root.frameThickness - height + root.weld
		clip: true
		visible: height > 2

		Osd {
			id: osdBody
			anchors.bottom: parent.bottom
			anchors.horizontalCenter: parent.horizontalCenter
			opacity: root.osdProgress > 0.72 ? 1 : 0

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
		visible: height > 2

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
			opacity: root.launcherProgress > 0.72 ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: Theme.fade }
			}
		}
	}

	Timer {
		id: statusTimer
		interval: Theme.hoverDelay
		onTriggered: {
			if (!cornerHover.hovered && !chipHover.hovered)
				root.statusWanted = false
		}
	}

	mask: Region {
		item: root.launcherHere ? dismiss : hotCorner

		Region {
			item: statusClip
		}
	}
}
