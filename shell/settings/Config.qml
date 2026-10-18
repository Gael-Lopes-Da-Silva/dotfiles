pragma Singleton

import QtQuick
import Quickshell

Singleton {
	readonly property string timeFormat: Settings.settings.timeFormat
	readonly property string monthFormat: Settings.settings.monthFormat
	readonly property string yearFormat: Settings.settings.yearFormat
	readonly property string weekdayFormat: Settings.settings.weekdayFormat
	readonly property var weekdays: Settings.settings.weekdays
	readonly property int clockTick: Settings.settings.clockTick

	readonly property int hoverDelay: Settings.settings.hoverDelay
	readonly property int hotCorner: Settings.settings.hotCorner
	readonly property real reveal: Settings.settings.reveal
	readonly property real menuReveal: Settings.settings.menuReveal
	readonly property int clipMin: Settings.settings.clipMin

	readonly property int osdHold: Settings.settings.osdHold
	readonly property int usbPoll: Settings.settings.usbPoll

	readonly property int notificationHold: Settings.settings.notificationHold
	readonly property int notificationTick: Settings.settings.notificationTick
	readonly property int reloadHold: Settings.settings.reloadHold
	readonly property int reloadFailHold: Settings.settings.reloadFailHold
	readonly property int noticeDedupe: Settings.settings.noticeDedupe
	readonly property int noticeHistory: Settings.settings.noticeHistory
	readonly property int noticeMinHeight: Settings.settings.noticeMinHeight
	readonly property real noticeHeightRatio: Settings.settings.noticeHeightRatio
	readonly property real noticeCenterRatio: Settings.settings.noticeCenterRatio
	readonly property string shellName: Settings.settings.shellName

	readonly property int launcherLimit: Settings.settings.launcherLimit
	readonly property var iconSizes: Settings.settings.iconSizes
	readonly property int networkLimit: Settings.settings.networkLimit
	readonly property int deviceLimit: Settings.settings.deviceLimit
	readonly property int audioLimit: Settings.settings.audioLimit

	readonly property int niriRetry: Settings.settings.niriRetry
	readonly property int fullscreenSlack: Settings.settings.fullscreenSlack
	readonly property int fullscreenMin: Settings.settings.fullscreenMin

	readonly property int powerPrime: Settings.settings.powerPrime
	readonly property int screenPrime: Settings.settings.screenPrime
	readonly property int lowBattery: Settings.settings.lowBattery

	readonly property int brightnessPoll: Settings.settings.brightnessPoll
	readonly property real brightnessEpsilon: Settings.settings.brightnessEpsilon

	readonly property int audioPoll: Settings.settings.audioPoll
	readonly property int audioListOpen: Settings.settings.audioListOpen
	readonly property int audioListIdle: Settings.settings.audioListIdle
	readonly property real volumeEpsilon: Settings.settings.volumeEpsilon
	readonly property real muteFloor: Settings.settings.muteFloor
	readonly property real volumeLow: Settings.settings.volumeLow
	readonly property real volumeMid: Settings.settings.volumeMid

	readonly property int radioRefreshOpen: Settings.settings.radioRefreshOpen
	readonly property int radioRefreshIdle: Settings.settings.radioRefreshIdle
	readonly property int rssiPoll: Settings.settings.rssiPoll
	readonly property int rssiUnknown: Settings.settings.rssiUnknown
	readonly property int rssiMin: Settings.settings.rssiMin
	readonly property int rssiMax: Settings.settings.rssiMax
	readonly property int rssiFloor: Settings.settings.rssiFloor
	readonly property int rssiSpan: Settings.settings.rssiSpan

	readonly property string internalScreens: Settings.settings.internalScreens

	readonly property real castGlyphScale: Settings.settings.castGlyphScale
	readonly property int castEdge: Settings.settings.castEdge
	readonly property int castNudge: Settings.settings.castNudge
	readonly property string mutedLabel: Settings.settings.mutedLabel
	readonly property string osdPlugged: Settings.settings.osdPlugged
	readonly property string osdUnplugged: Settings.settings.osdUnplugged
	readonly property string osdChargerOn: Settings.settings.osdChargerOn
	readonly property string osdChargerOff: Settings.settings.osdChargerOff
	readonly property string osdAudioMuted: Settings.settings.osdAudioMuted
	readonly property string osdMicMuted: Settings.settings.osdMicMuted
	readonly property string osdUsbName: Settings.settings.osdUsbName
	readonly property string osdScreenName: Settings.settings.osdScreenName
	readonly property string powerLap: Settings.settings.powerLap
	readonly property string powerHot: Settings.settings.powerHot
	readonly property var niriEvent: Settings.settings.niriEvent
	readonly property var screenshotCommand: Settings.settings.screenshotCommand
	readonly property var sessionActions: Settings.settings.sessionActions
	readonly property var batterySteps: Settings.settings.batterySteps

	readonly property string record: Settings.icons.record
	readonly property string power: Settings.icons.power
	readonly property string screenshot: Settings.icons.screenshot
	readonly property string clock: Settings.icons.clock
	readonly property string bell: Settings.icons.bell
	readonly property string bellOff: Settings.icons.bellOff
	readonly property string alert: Settings.icons.alert
	readonly property string check: Settings.icons.check
	readonly property string lock: Settings.icons.lock
	readonly property string search: Settings.icons.search
	readonly property string reply: Settings.icons.reply
	readonly property string wifiOff: Settings.icons.wifiOff
	readonly property string wifiIdle: Settings.icons.wifiIdle
	readonly property string btOff: Settings.icons.btOff
	readonly property string btIdle: Settings.icons.btIdle
	readonly property string btOn: Settings.icons.btOn
	readonly property string usb: Settings.icons.usb
	readonly property string screenOn: Settings.icons.screenOn
	readonly property string screenOff: Settings.icons.screenOff
	readonly property string brightness: Settings.icons.brightness
	readonly property string chargerOn: Settings.icons.chargerOn
	readonly property string chargerOff: Settings.icons.chargerOff
	readonly property var volumeIcons: Settings.icons.volume
	readonly property var micIcons: Settings.icons.mic
	readonly property var wifiBars: Settings.icons.wifiBars
	readonly property var batteryCharging: Settings.icons.batteryCharging
	readonly property var batteryDischarging: Settings.icons.batteryDischarging

	function icon(code) {
		return String.fromCodePoint(parseInt(code, 16))
	}
}
