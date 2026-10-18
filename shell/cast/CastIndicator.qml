import QtQuick
import qs

Item {
	id: root

	property string mode: "recording"
	property string output: ""
	property real iconSize: Theme.clockSize

	readonly property int glyphSize: Math.round(iconSize * 0.68)
	readonly property int edge: 1
	readonly property int iconNudge: 4
	readonly property real buttonSide: castMetrics.advanceWidth

	width: implicitWidth
	height: implicitHeight
	implicitWidth: buttonSide + edge + iconNudge
	implicitHeight: buttonSide + edge + iconNudge

	TextMetrics {
		id: castMetrics
		font.family: Theme.iconFont
		font.pixelSize: root.glyphSize
		text: String.fromCodePoint(0xF044A)
	}

	Item {
		id: glyphBox
		x: root.edge
		y: root.edge
		width: root.buttonSide
		height: root.buttonSide
	}

	Text {
		anchors.centerIn: glyphBox
		anchors.horizontalCenterOffset: root.iconNudge
		anchors.verticalCenterOffset: root.iconNudge
		text: String.fromCodePoint(0xF044A)
		color: Theme.recording
		font.family: Theme.iconFont
		font.pixelSize: root.glyphSize
	}
}
