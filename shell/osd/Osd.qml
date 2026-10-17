import QtQuick
import qs
import qs.services

Item {
	id: root

	readonly property string kind: NiriState.osdKind
	readonly property bool discrete: kind === "usb" || kind === "screen"
	readonly property real amount: {
		if (kind === "brightness")
			return BrightnessState.level
		if (kind === "power")
			return PowerState.level
		if (kind === "microphone")
			return AudioState.micMuted ? 0 : AudioState.micVolume
		if (AudioState.muted)
			return 0
		return AudioState.volume
	}
	readonly property real bar: Math.max(0, Math.min(1, amount))
	readonly property string label: {
		if (kind === "usb" || kind === "screen") {
			const name = NiriState.osdText || (kind === "usb" ? "USB" : "Screen")
			return name + (NiriState.osdOn ? " plugged in" : " unplugged")
		}
		if (kind === "power")
			return PowerState.plugged ? "Plugged in" : "Unplugged"
		if (kind === "brightness")
			return Math.round(amount * 100) + "%"
		if (kind === "microphone")
			return AudioState.levelText(AudioState.micVolume, AudioState.micMuted)
		if (AudioState.muted)
			return "Muted"
		return Math.round(amount * 100) + "%"
	}
	readonly property string glyph: {
		if (kind === "usb")
			return String.fromCodePoint(0xF0A72)
		if (kind === "screen")
			return String.fromCodePoint(NiriState.osdOn ? 0xF0379 : 0xF0D57)
		if (kind === "power")
			return String.fromCodePoint(PowerState.plugged ? 0xF06A5 : 0xF06A6)
		if (kind === "brightness")
			return String.fromCodePoint(0xF00DF)
		if (kind === "microphone")
			return AudioState.micGlyph(AudioState.micMuted || amount <= Config.muteFloor)
		if (AudioState.muted || amount <= Config.muteFloor)
			return String.fromCodePoint(0xF075F)
		if (amount < Config.volumeLow)
			return String.fromCodePoint(0xF057F)
		if (amount < Config.volumeMid)
			return String.fromCodePoint(0xF0580)
		return String.fromCodePoint(0xF057E)
	}

	implicitWidth: row.implicitWidth + Theme.padding * 2
	implicitHeight: row.implicitHeight + Theme.padding * 2

	Row {
		id: row
		anchors.centerIn: parent
		spacing: Theme.gap

		Text {
			text: root.glyph
			color: Theme.foreground
			font.family: Theme.iconFont
			font.pixelSize: Theme.iconSize
			anchors.verticalCenter: parent.verticalCenter
		}

		Rectangle {
			visible: !root.discrete
			implicitWidth: Theme.osdBarWidth
			implicitHeight: Theme.osdBarHeight
			radius: Theme.osdBarHeight / 2
			color: Theme.ink(Theme.buttonHover)
			anchors.verticalCenter: parent.verticalCenter

			Rectangle {
				width: parent.width * root.bar
				height: parent.height
				radius: parent.radius
				color: Theme.foreground
			}
		}

		Text {
			text: root.label
			color: Theme.foreground
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			width: root.discrete ? Math.min(contentWidth, Theme.osdLabelWidth) : contentWidth
			elide: Text.ElideRight
			anchors.verticalCenter: parent.verticalCenter
		}
	}
}
