pragma Singleton

import QtQuick
import Quickshell

Singleton {
	readonly property color background: "#242424"
	readonly property color foreground: "#eeeeee"

	readonly property int radius: 12
	readonly property int padding: 14
	readonly property int gap: 10
	readonly property int fade: 140
	readonly property int travel: 8

	// Niri struts use `frame`. Window geometry radius uses `innerRadius`.
	readonly property int frame: 4
	readonly property int screenRadius: 12
	readonly property int innerRadius: screenRadius
	readonly property int motion: 450
	readonly property var curve: [0.38, 1.21, 0.22, 1, 1, 1]
	readonly property int smoothing: 24
	readonly property int weld: 12
	readonly property int osdHold: 2000
	readonly property int hoverDelay: 200

	readonly property int fontSize: 14
	readonly property int clockSize: 22
	readonly property string fontFamily: "Noto Sans"
	readonly property string iconFont: "Symbols Nerd Font"
}
