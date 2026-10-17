pragma Singleton

import QtQuick
import Quickshell

Singleton {
	readonly property color background: "#242424"
	readonly property color foreground: "#eeeeee"
	readonly property color border: "#404040"

	readonly property int barHeight: 32
	readonly property int fontSize: 14
	readonly property string fontFamily: "Noto Sans"
}
