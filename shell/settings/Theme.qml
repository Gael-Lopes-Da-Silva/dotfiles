pragma Singleton

import QtQuick
import Quickshell

Singleton {
	readonly property color background: Settings.theme.background
	readonly property color foreground: Settings.theme.foreground
	readonly property color recording: Settings.theme.recording
	readonly property color link: Settings.theme.link

	readonly property string fontFamily: Settings.theme.fontFamily
	readonly property string monoFamily: Settings.theme.monoFamily
	readonly property string iconFont: Settings.theme.iconFont

	readonly property int fontSize: Settings.theme.fontSize
	readonly property int clockSize: Settings.theme.clockSize
	readonly property int titleSize: Settings.theme.titleSize
	readonly property int monthSize: Settings.theme.monthSize
	readonly property int yearSize: Settings.theme.yearSize
	readonly property int headingSize: Settings.theme.headingSize
	readonly property int iconSize: Settings.theme.iconSize
	readonly property int glyphSize: Settings.theme.glyphSize
	readonly property int smallSize: Settings.theme.smallSize
	readonly property int labelSize: Settings.theme.labelSize
	readonly property int searchIconSize: Settings.theme.searchIconSize
	readonly property int noticeIcon: Settings.theme.noticeIcon

	readonly property int radius: Settings.theme.radius
	readonly property int rowRadius: Settings.theme.rowRadius
	readonly property int buttonRadius: Settings.theme.buttonRadius
	readonly property int searchRadius: Settings.theme.searchRadius
	readonly property int padding: Settings.theme.padding
	readonly property int gap: Settings.theme.gap
	readonly property int inset: Settings.theme.inset
	readonly property int chipPadX: Settings.theme.chipPadX
	readonly property int chipPadY: Settings.theme.chipPadY
	readonly property int chipGap: Settings.theme.chipGap
	readonly property int headerInset: Settings.theme.headerInset
	readonly property int edgeInset: Settings.theme.edgeInset

	readonly property int rowHeight: Settings.theme.rowHeight
	readonly property int rowInnerHeight: Settings.theme.rowInnerHeight
	readonly property int well: Settings.theme.well
	readonly property int menuSpacing: Settings.theme.menuSpacing

	readonly property int frame: Settings.theme.frame
	readonly property color border: Settings.theme.border
	readonly property int borderWidth: Settings.theme.borderWidth
	readonly property int screenRadius: Settings.theme.screenRadius
	readonly property int innerRadius: Settings.theme.innerRadius
	readonly property int weld: Settings.theme.weld
	readonly property int smoothing: Settings.theme.smoothing

	readonly property int motion: Settings.theme.motion
	readonly property int fade: Settings.theme.fade
	readonly property int travel: Settings.theme.travel
	readonly property var curve: Settings.theme.curve

	readonly property real selected: Settings.theme.selected
	readonly property real hover: Settings.theme.hover
	readonly property real wash: Settings.theme.wash
	readonly property real wellFill: Settings.theme.wellFill
	readonly property real track: Settings.theme.track
	readonly property real field: Settings.theme.field
	readonly property real buttonHover: Settings.theme.buttonHover
	readonly property real muted: Settings.theme.muted
	readonly property real dim: Settings.theme.dim
	readonly property real quiet: Settings.theme.quiet
	readonly property real iconMute: Settings.theme.iconMute
	readonly property real signalFloor: Settings.theme.signalFloor
	readonly property real signalIdle: Settings.theme.signalIdle
	readonly property real body: Settings.theme.body
	readonly property real scroll: Settings.theme.scroll

	readonly property int clockMenuWidth: Settings.theme.clockMenuWidth
	readonly property int radioMenuWidth: Settings.theme.radioMenuWidth
	readonly property int sessionMenuWidth: Settings.theme.sessionMenuWidth
	readonly property int launcherWidth: Settings.theme.launcherWidth
	readonly property int launcherRow: Settings.theme.launcherRow
	readonly property int launcherIcon: Settings.theme.launcherIcon
	readonly property int launcherText: Settings.theme.launcherText
	readonly property int notificationWidth: Settings.theme.notificationWidth
	readonly property int calendarCell: Settings.theme.calendarCell
	readonly property int todaySize: Settings.theme.todaySize
	readonly property int weekdayHeight: Settings.theme.weekdayHeight
	readonly property int batteryHeader: Settings.theme.batteryHeader
	readonly property int batteryBar: Settings.theme.batteryBar

	readonly property int toggleWidth: Settings.theme.toggleWidth
	readonly property int toggleHeight: Settings.theme.toggleHeight
	readonly property int toggleKnob: Settings.theme.toggleKnob
	readonly property int toggleInset: Settings.theme.toggleInset
	readonly property int sliderTrack: Settings.theme.sliderTrack
	readonly property int sliderThumb: Settings.theme.sliderThumb
	readonly property int sliderRow: Settings.theme.sliderRow
	readonly property int sliderSlot: Settings.theme.sliderSlot
	readonly property int streamRow: Settings.theme.streamRow
	readonly property int replyIcon: Settings.theme.replyIcon

	readonly property int osdBarWidth: Settings.theme.osdBarWidth
	readonly property int osdBarHeight: Settings.theme.osdBarHeight
	readonly property int osdLabelWidth: Settings.theme.osdLabelWidth

	readonly property int noticeImageHeight: Settings.theme.noticeImageHeight
	readonly property int noticeImageSource: Settings.theme.noticeImageSource
	readonly property int noticeActionHeight: Settings.theme.noticeActionHeight
	readonly property int noticeReply: Settings.theme.noticeReply
	readonly property int noticeProgress: Settings.theme.noticeProgress
	readonly property int noticeSummaryLines: Settings.theme.noticeSummaryLines
	readonly property int noticeBodyLines: Settings.theme.noticeBodyLines
	readonly property int noticeErrorLines: Settings.theme.noticeErrorLines

	function ink(alpha) {
		const color = foreground
		return Qt.rgba(color.r, color.g, color.b, alpha)
	}
}
