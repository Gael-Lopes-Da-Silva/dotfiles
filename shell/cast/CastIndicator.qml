import QtQuick
import qs
import qs.services

Item {
	id: root

	property string mode: "recording"
	property string output: ""
	property bool shown: false
	property bool hovered: pointer.containsMouse
	property real iconSize: Theme.clockSize
	property real shrink: 0
	property bool animateSize: true

	readonly property real open: Math.max(0, 1 - shrink)
	readonly property real margin: Theme.padding * open
	readonly property real edge: Math.max(1, margin)
	readonly property real iconNudge: 2 * shrink
	readonly property real buttonWidth: fullIcon.implicitWidth / (1 + 1 * shrink) + Theme.padding * 1.5 * open
	readonly property real buttonHeight: fullIcon.implicitHeight / (1 + 1 * shrink) + Theme.padding * 1.5 * open

	width: implicitWidth
	height: implicitHeight
	implicitWidth: buttonWidth + edge + margin + iconNudge
	implicitHeight: buttonHeight + edge + margin + iconNudge

	function present() {
		settle.stop()
		animateSize = false
		iconSize = Theme.clockSize
		shrink = 0
		animateSize = true
		settle.interval = Config.castSettle
		settle.restart()
	}

	onShownChanged: {
		if (shown)
			present()
		else
			settle.stop()
	}

	Component.onCompleted: {
		if (shown)
			present()
	}

	Behavior on shrink {
		enabled: root.animateSize
		NumberAnimation {
			duration: Theme.motion
			easing.type: Easing.BezierSpline
			easing.bezierCurve: Theme.curve
		}
	}

	Timer {
		id: settle
		interval: Config.castSettle
		onTriggered: {
			if (!root.hovered)
				root.shrink = 1
		}
	}

	MouseArea {
		id: pointer
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onContainsMouseChanged: {
			if (containsMouse) {
				settle.stop()
				root.shrink = 0
			} else if (root.shown) {
				settle.interval = Config.castHoverSettle
				settle.restart()
			}
		}
		onClicked: NiriState.stopCasts(root.output)
	}

	Text {
		id: fullIcon
		visible: false
		text: String.fromCodePoint(root.mode === "casting" ? 0xF0118 : 0xF0EC2)
		font.family: Theme.iconFont
		font.pixelSize: root.iconSize
	}

	Rectangle {
		id: buttonFace
		x: root.edge
		y: root.edge
		width: root.buttonWidth
		height: root.buttonHeight
		radius: Theme.buttonRadius
		color: root.hovered ? Theme.ink(Theme.hover) : "transparent"
	}

	Text {
		id: icon
		anchors.centerIn: buttonFace
		anchors.horizontalCenterOffset: root.iconNudge
		anchors.verticalCenterOffset: root.iconNudge
		text: String.fromCodePoint(root.hovered ? 0xF10D3 : (root.mode === "casting" ? 0xF0118 : 0xF0EC2))
		color: Theme.recording
		font.family: Theme.iconFont
		font.pixelSize: root.iconSize / (1 + root.shrink)
	}
}
