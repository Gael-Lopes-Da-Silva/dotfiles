// Shared look from config.json "theme": colors, type, spacing, motion, and ink().
// Sizes that belong to one widget live on that widget's Config section, not here.

pragma Singleton

import QtQuick
import Quickshell

Singleton {
	readonly property color background: Config.theme.background
	readonly property color foreground: Config.theme.foreground
	readonly property color recording: Config.theme.recording
	readonly property color link: Config.theme.link

	readonly property string fontFamily: Config.theme.fontFamily
	readonly property string monoFamily: Config.theme.monoFamily
	readonly property string iconFont: Config.theme.iconFont

	readonly property int fontSize: Config.theme.fontSize
	readonly property int smallSize: Config.theme.smallSize
	readonly property int labelSize: Config.theme.labelSize
	readonly property int headingSize: Config.theme.headingSize
	readonly property int iconSize: Config.theme.iconSize
	readonly property int glyphSize: Config.theme.glyphSize
	readonly property int chipIcon: Config.theme.chipIcon

	readonly property int radius: Config.theme.radius
	readonly property int rowRadius: Config.theme.rowRadius
	readonly property int buttonRadius: Config.theme.buttonRadius
	readonly property int padding: Config.theme.padding
	readonly property int gap: Config.theme.gap
	readonly property int inset: Config.theme.inset
	readonly property int rowHeight: Config.theme.rowHeight
	readonly property int rowInnerHeight: Config.theme.rowInnerHeight
	readonly property int menuSpacing: Config.theme.menuSpacing
	readonly property int menuInset: Config.theme.menuInset
	readonly property int menuEdge: Config.theme.menuEdge
	readonly property int iconWell: Config.theme.iconWell
	readonly property int scrollSize: Config.theme.scrollSize

	readonly property int toggleWidth: Config.theme.toggleWidth
	readonly property int toggleHeight: Config.theme.toggleHeight
	readonly property int toggleKnob: Config.theme.toggleKnob
	readonly property int toggleInset: Config.theme.toggleInset

	readonly property int motion: Config.theme.motion
	readonly property int fade: Config.theme.fade
	readonly property var curve: Config.theme.curve

	readonly property real selected: Config.theme.selected
	readonly property real hover: Config.theme.hover
	readonly property real wash: Config.theme.wash
	readonly property real wellFill: Config.theme.wellFill
	readonly property real track: Config.theme.track
	readonly property real field: Config.theme.field
	readonly property real buttonHover: Config.theme.buttonHover
	readonly property real muted: Config.theme.muted
	readonly property real dim: Config.theme.dim
	readonly property real quiet: Config.theme.quiet
	readonly property real iconMuted: Config.theme.iconMuted
	readonly property real body: Config.theme.body
	readonly property real scroll: Config.theme.scroll

	// Foreground at the given opacity. Alphas come from the theme section.
	function ink(alpha) {
		const color = foreground
		return Qt.rgba(color.r, color.g, color.b, alpha)
	}
}
