import QtQuick
import qs.settings

Item {
	id: root

	property string mode: "recording"
	property string output: ""
	property real iconSize: Theme.clockSize

	readonly property int glyphSize: Math.round(iconSize * Config.castGlyphScale)
	readonly property int edge: Config.castEdge
	readonly property int iconNudge: Config.castNudge
	readonly property real buttonSide: castMetrics.advanceWidth

	width: implicitWidth
	height: implicitHeight
	implicitWidth: buttonSide + edge + iconNudge
	implicitHeight: buttonSide + edge + iconNudge

	TextMetrics {
		id: castMetrics
		font.family: Theme.iconFont
		font.pixelSize: root.glyphSize
		text: Config.icon(Config.record)
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
		text: Config.icon(Config.record)
		color: Theme.recording
		font.family: Theme.iconFont
		font.pixelSize: root.glyphSize
	}
}
