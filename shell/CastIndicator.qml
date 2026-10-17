import QtQuick

Item {
	id: root

	property string mode: "recording"
	property bool shown: false
	property real iconSize: Theme.clockSize
	property real shrink: 0
	property bool animateSize: true

	readonly property real fullWidth: fullIcon.implicitWidth + Theme.padding * 1.5
	readonly property real fullHeight: fullIcon.implicitHeight + Theme.padding * 1.5

	implicitWidth: fullWidth / (1 + 1 * shrink)
	implicitHeight: fullHeight / (1 + 1 * shrink)

	function present() {
		settle.stop()
		animateSize = false
		iconSize = Theme.clockSize
		shrink = 0
		animateSize = true
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
		interval: Theme.castSettle
		onTriggered: root.shrink = 1
	}

	Text {
		id: fullIcon
		visible: false
		text: icon.text
		font.family: Theme.iconFont
		font.pixelSize: root.iconSize
	}

	Text {
		id: icon
		anchors.centerIn: parent
		text: String.fromCodePoint(root.mode === "casting" ? 0xF0118 : 0xF0EC2)
		color: Theme.recording
		font.family: Theme.iconFont
		font.pixelSize: root.iconSize / (1 + root.shrink)
	}
}
