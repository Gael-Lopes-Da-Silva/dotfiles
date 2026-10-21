// Draggable level bar on the audio and microphone pages.
import QtQuick
import qs.settings

Item {
	id: root

	property real value: 0
	property real slide: 0
	readonly property real shown: drag.pressed ? slide : value
	signal moved(real amount)

	implicitHeight: Config.audio.sliderRow

	Rectangle {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.leftMargin: Theme.inset - Theme.menuInset
		anchors.rightMargin: Theme.inset - Theme.menuInset
		anchors.verticalCenter: parent.verticalCenter
		height: Config.audio.sliderSlot
		radius: Theme.rowRadius
		color: drag.containsMouse || drag.pressed ? Theme.ink(Theme.hover) : "transparent"
	}

	Rectangle {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		height: Config.audio.sliderTrack
		radius: Config.audio.sliderTrack / 2
		color: Theme.ink(Theme.track)

		Rectangle {
			width: parent.width * Math.max(0, Math.min(1, root.shown))
			height: parent.height
			radius: parent.radius
			color: Theme.foreground
		}
	}

	Rectangle {
		width: Config.audio.sliderThumb
		height: Config.audio.sliderThumb
		radius: Config.audio.sliderThumb / 2
		anchors.verticalCenter: parent.verticalCenter
		x: Math.max(0, Math.min(parent.width - width, parent.width * root.shown - width / 2))
		color: Theme.foreground
	}

	MouseArea {
		id: drag
		anchors.fill: parent
		hoverEnabled: true
		preventStealing: true
		cursorShape: Qt.PointingHandCursor
		onPressed: mouse => apply(mouse.x)
		onPositionChanged: mouse => {
			if (pressed)
				apply(mouse.x)
		}

		function apply(x) {
			const amount = Math.max(0, Math.min(1, x / width))
			root.slide = amount
			root.moved(amount)
		}
	}
}
