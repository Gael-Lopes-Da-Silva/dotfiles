pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	FileView {
		path: Quickshell.shellPath("config.json")
		watchChanges: true
		blockWrites: true
		preload: true
		printErrors: true
		onFileChanged: reload()

		JsonAdapter {
			id: adapter

			property JsonObject theme: JsonObject {
				property string background: "#121212"
				property string foreground: "#eeeeee"
				property string recording: "#ff5c5c"
				property string link: "#9ecbff"
				property string fontFamily: "Noto Sans"
				property string monoFamily: "monospace"
				property string iconFont: "Symbols Nerd Font"
				property int fontSize: 14
				property int clockSize: 22
				property int titleSize: 18
				property int monthSize: 22
				property int yearSize: 16
				property int headingSize: 15
				property int iconSize: 20
				property int glyphSize: 16
				property int smallSize: 13
				property int labelSize: 12
				property int searchIconSize: 18
				property int noticeIcon: 18
				property int radius: 12
				property int rowRadius: 10
				property int buttonRadius: 8
				property int searchRadius: 14
				property int padding: 14
				property int gap: 10
				property int inset: 8
				property int chipPadX: 8
				property int chipPadY: 2
				property int chipGap: 8
				property int headerInset: 20
				property int edgeInset: 18
				property int rowHeight: 44
				property int rowInnerHeight: 40
				property int well: 28
				property int menuSpacing: 4
				property int frame: 6
				property string border: "#282828"
				property int borderWidth: 1
				property int screenRadius: 20
				property int innerRadius: 20
				property int weld: 12
				property int smoothing: 24
				property int motion: 450
				property int fade: 140
				property int travel: 8
				property var curve: [0.38, 1.21, 0.22, 1, 1, 1]
				property real selected: 0.12
				property real hover: 0.07
				property real wash: 0.06
				property real wellFill: 0.08
				property real track: 0.16
				property real field: 0.1
				property real buttonHover: 0.18
				property real muted: 0.45
				property real dim: 0.4
				property real quiet: 0.5
				property real iconMute: 0.55
				property real signalFloor: 0.55
				property real signalIdle: 0.8
				property real body: 0.82
				property real scroll: 0.35
				property int clockMenuWidth: 292
				property int radioMenuWidth: 320
				property int sessionMenuWidth: 240
				property int launcherWidth: 440
				property int launcherRow: 48
				property int launcherIcon: 26
				property int launcherText: 18
				property int notificationWidth: 340
				property int calendarCell: 36
				property int todaySize: 30
				property int weekdayHeight: 24
				property int batteryHeader: 64
				property int batteryBar: 6
				property int toggleWidth: 38
				property int toggleHeight: 22
				property int toggleKnob: 16
				property int toggleInset: 3
				property int sliderTrack: 5
				property int sliderThumb: 14
				property int sliderRow: 22
				property int sliderSlot: 28
				property int streamRow: 64
				property int replyIcon: 16
				property int osdBarWidth: 148
				property int osdBarHeight: 4
				property int osdLabelWidth: 240
				property int noticeImageHeight: 160
				property int noticeImageSource: 360
				property int noticeActionHeight: 28
				property int noticeReply: 32
				property int noticeProgress: 3
				property int noticeSummaryLines: 2
				property int noticeBodyLines: 8
				property int noticeErrorLines: 16
			}

			property JsonObject settings: JsonObject {
				property string timeFormat: "HH:mm"
				property string monthFormat: "MMMM"
				property string yearFormat: "yyyy"
				property string weekdayFormat: "dddd"
				property var weekdays: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
				property int clockTick: 1000
				property int hoverDelay: 200
				property int hotCorner: 16
				property real reveal: 0.72
				property real menuReveal: 0.45
				property int clipMin: 2
				property int osdHold: 2000
				property int usbPoll: 500
				property int notificationHold: 5000
				property int notificationTick: 50
				property int reloadHold: 2500
				property int reloadFailHold: 8000
				property int noticeDedupe: 800
				property int noticeHistory: 40
				property int noticeMinHeight: 180
				property real noticeHeightRatio: 0.45
				property real noticeCenterRatio: 0.36
				property real audioMenuRatio: 0.48
				property string shellName: "Quickshell"
				property int launcherLimit: 8
				property var iconSizes: ["512x512", "512x512@2", "256x256", "256x256@2", "128x128", "128x128@2", "64x64", "48x48", "32x32"]
				property int networkLimit: 8
				property int deviceLimit: 8
				property int audioLimit: 12
				property int niriRetry: 1000
				property int fullscreenSlack: 8
				property int fullscreenMin: 100
				property int powerPrime: 400
				property int screenPrime: 800
				property int lowBattery: 15
				property int brightnessPoll: 250
				property real brightnessEpsilon: 0.002
				property int audioPoll: 500
				property int audioListOpen: 1000
				property int audioListIdle: 3000
				property real volumeEpsilon: 0.005
				property real muteFloor: 0.001
				property real volumeLow: 0.33
				property real volumeMid: 0.66
				property int radioRefreshOpen: 1500
				property int radioRefreshIdle: 4000
				property int radioWarmup: 8000
				property int rssiPoll: 2000
				property int rssiUnknown: -999
				property int rssiMin: -200
				property int rssiMax: 20
				property int rssiFloor: -100
				property int rssiSpan: 55
				property string internalScreens: "^(eDP|LVDS|DSI|Virtual)"
				property real castGlyphScale: 0.68
				property int castEdge: 1
				property int castNudge: 4
				property string mutedLabel: "Muted"
				property string osdPlugged: " plugged in"
				property string osdUnplugged: " unplugged"
				property string osdChargerOn: "Charger plugged in"
				property string osdChargerOff: "Charger unplugged"
				property string osdAudioMuted: "Audio muted"
				property string osdMicMuted: "Microphone muted"
				property string osdUsbName: "USB"
				property string osdScreenName: "Screen"
				property string powerLap: "Limited while on your lap"
				property string powerHot: "Limited while the laptop is hot"
				property string batteryLow: "Battery low"
				property string batteryRemaining: "% remaining"
				property string batteryFull: "Fully charged"
				property var niriEvent: ["niri", "msg", "--json", "event-stream"]
				property var screenshotCommand: ["niri", "msg", "action", "screenshot", "--show-pointer", "false"]
				property var pickColorCommand: ["niri", "msg", "--json", "pick-color"]
				property var sessionActions: [
					{ icon: "F0904", label: "Suspend", command: ["systemctl", "suspend"] },
					{ icon: "F0709", label: "Restart", command: ["systemctl", "reboot"] },
					{ icon: "F0425", label: "Shut down", command: ["systemctl", "poweroff"] },
					{ icon: "F0343", label: "Log out", command: ["niri", "msg", "action", "quit"] }
				]
				property var batterySteps: [95, 85, 75, 65, 55, 45, 35, 25, 15, 5]
			}

			property JsonObject icons: JsonObject {
				property string record: "F044A"
				property string power: "F0425"
				property string screenshot: "F0E51"
				property string eyedropper: "F020A"
				property string clock: "F0150"
				property string bell: "F009A"
				property string bellOff: "F00A0"
				property string alert: "F0026"
				property string check: "F012C"
				property string lock: "F033E"
				property string search: "F0349"
				property string reply: "F048A"
				property string wifiOff: "F05AA"
				property string wifiIdle: "F092A"
				property string ethernet: "F0200"
				property string btOff: "F00B2"
				property string btIdle: "F00AF"
				property string btOn: "F00B1"
				property string usb: "F129E"
				property string screenOn: "F0379"
				property string screenOff: "F0D57"
				property string brightness: "F00DF"
				property string chargerOn: "F06A5"
				property string chargerOff: "F06A6"
				property var volume: ["F075F", "F057F", "F0580", "F057E"]
				property var mic: ["F036D", "F036C"]
				property var wifiBars: ["F091F", "F0922", "F0925", "F0928"]
				property var batteryCharging: ["F0085", "F008B", "F008A", "F089E", "F0089", "F089D", "F0088", "F0087", "F0086", "F089C", "F0084"]
				property var batteryDischarging: ["F0079", "F0082", "F0081", "F0080", "F007F", "F007E", "F007D", "F007C", "F007B", "F007A", "F008E"]
			}
		}
	}

	readonly property var theme: adapter.theme
	readonly property var settings: adapter.settings
	readonly property var icons: adapter.icons
}
