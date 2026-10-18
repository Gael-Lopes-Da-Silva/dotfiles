pragma Singleton

import QtQuick
import Quickshell

// Colors, type, spacing, and motion.
Singleton {
	readonly property color background: "#242424"
	readonly property color foreground: "#eeeeee"
	readonly property color recording: "#ff5c5c"
	readonly property color link: "#9ecbff"

	readonly property string fontFamily: "Noto Sans"
	readonly property string monoFamily: "monospace"
	readonly property string iconFont: "Symbols Nerd Font"

	readonly property int fontSize: 14
	readonly property int clockSize: 22
	readonly property int titleSize: fontSize + 4
	readonly property int monthSize: fontSize + 8
	readonly property int yearSize: fontSize + 2
	readonly property int headingSize: fontSize + 1
	readonly property int iconSize: fontSize + 6
	readonly property int glyphSize: fontSize + 2
	readonly property int smallSize: fontSize - 1
	readonly property int labelSize: fontSize - 2
	readonly property int searchIconSize: 18
	readonly property int noticeIcon: 18

	readonly property int radius: 12
	readonly property int rowRadius: 10
	readonly property int buttonRadius: 8
	readonly property int searchRadius: 14
	readonly property int padding: 14
	readonly property int gap: 10
	readonly property int inset: 8
	readonly property int chipPadX: 8
	readonly property int chipPadY: 2
	readonly property int chipGap: 8
	readonly property int headerInset: 20
	readonly property int edgeInset: 18

	readonly property int rowHeight: 44
	readonly property int rowInnerHeight: 40
	readonly property int well: 28
	readonly property int menuSpacing: 4

	readonly property int frame: 2
	readonly property int screenRadius: 20
	readonly property int innerRadius: screenRadius
	readonly property int weld: 12
	readonly property int smoothing: 24

	readonly property int motion: 450
	readonly property int fade: 140
	readonly property int travel: 8
	readonly property var curve: [0.38, 1.21, 0.22, 1, 1, 1]

	readonly property real selected: 0.12
	readonly property real hover: 0.07
	readonly property real wash: 0.06
	readonly property real wellFill: 0.08
	readonly property real track: 0.16
	readonly property real field: 0.1
	readonly property real buttonHover: 0.18
	readonly property real muted: 0.45
	readonly property real dim: 0.4
	readonly property real quiet: 0.5
	readonly property real iconMute: 0.55
	readonly property real signalFloor: 0.55
	readonly property real signalIdle: 0.8
	readonly property real body: 0.82
	readonly property real scroll: 0.35

	readonly property int clockMenuWidth: 292
	readonly property int radioMenuWidth: 320
	readonly property int sessionMenuWidth: 240
	readonly property int launcherWidth: 440
	readonly property int launcherRow: 48
	readonly property int launcherIcon: 26
	readonly property int launcherText: fontSize + 4
	readonly property int notificationWidth: 340
	readonly property int calendarCell: 36
	readonly property int todaySize: 30
	readonly property int weekdayHeight: 24
	readonly property int batteryHeader: 64
	readonly property int batteryBar: 6

	readonly property int toggleWidth: 38
	readonly property int toggleHeight: 22
	readonly property int toggleKnob: 16
	readonly property int toggleInset: 3
	readonly property int sliderTrack: 5
	readonly property int sliderThumb: 14
	readonly property int sliderRow: 22
	readonly property int sliderSlot: 28
	readonly property int streamRow: 64
	readonly property int replyIcon: 16

	readonly property int osdBarWidth: 148
	readonly property int osdBarHeight: 4
	readonly property int osdLabelWidth: 240

	readonly property int noticeImageHeight: 160
	readonly property int noticeImageSource: 360
	readonly property int noticeActionHeight: 28
	readonly property int noticeReply: 32
	readonly property int noticeProgress: 3
	readonly property int noticeSummaryLines: 2
	readonly property int noticeBodyLines: 8
	readonly property int noticeErrorLines: 16

	function ink(alpha) {
		const color = foreground
		return Qt.rgba(color.r, color.g, color.b, alpha)
	}
}
