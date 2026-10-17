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

	readonly property int fontSize: 14
	readonly property string fontFamily: "Noto Sans"
	readonly property string iconFont: "Symbols Nerd Font"
}
