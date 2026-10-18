pragma Singleton

import QtQuick
import Quickshell

// Timing, limits, and behavior.
Singleton {
	readonly property string timeFormat: "HH:mm"
	readonly property string monthFormat: "MMMM"
	readonly property string yearFormat: "yyyy"
	readonly property string weekdayFormat: "dddd"
	readonly property var weekdays: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
	readonly property int clockTick: 1000

	readonly property int hoverDelay: 200
	readonly property int hotCorner: 16
	readonly property real reveal: 0.72
	readonly property real menuReveal: 0.45
	readonly property int clipMin: 2

	readonly property int osdHold: 2000
	readonly property int usbPoll: 500
	readonly property int castSettle: 2000

	readonly property int notificationHold: 5000
	readonly property int notificationTick: 50
	readonly property int reloadHold: 2500
	readonly property int reloadFailHold: 8000
	readonly property int noticeDedupe: 800
	readonly property int noticeHistory: 40
	readonly property int noticeMinHeight: 180
	readonly property real noticeHeightRatio: 0.45
	readonly property real noticeCenterRatio: 0.36
	readonly property string shellName: "Quickshell"

	readonly property int launcherLimit: 8
	readonly property var iconSizes: [
		"512x512", "512x512@2", "256x256", "256x256@2",
		"128x128", "128x128@2", "64x64", "48x48", "32x32"
	]
	readonly property int networkLimit: 8
	readonly property int deviceLimit: 8
	readonly property int audioLimit: 6

	readonly property int niriRetry: 1000
	readonly property int fullscreenSlack: 8
	readonly property int fullscreenMin: 100

	readonly property int powerPrime: 400
	readonly property int screenPrime: 800
	readonly property int lowBattery: 15

	readonly property int brightnessPoll: 250
	readonly property real brightnessEpsilon: 0.002

	readonly property int audioPoll: 500
	readonly property int audioListOpen: 1000
	readonly property int audioListIdle: 3000
	readonly property real volumeEpsilon: 0.005
	readonly property real muteFloor: 0.001
	readonly property real volumeLow: 0.33
	readonly property real volumeMid: 0.66

	readonly property int radioRefreshOpen: 1500
	readonly property int radioRefreshIdle: 4000
	readonly property int rssiPoll: 2000
	readonly property int rssiUnknown: -999
	readonly property int rssiMin: -200
	readonly property int rssiMax: 20
	readonly property int rssiFloor: -100
	readonly property int rssiSpan: 55

	readonly property string internalScreens: "^(eDP|LVDS|DSI|Virtual)"
}
