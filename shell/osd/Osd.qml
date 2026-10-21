// On-screen display for volume, microphone, brightness, power, USB, and screens.
import QtQuick
import qs.services
import qs.settings

Item {
	id: root

	readonly property string kind: NiriState.osdKind
	readonly property bool discrete: kind === "usb" || kind === "screen" || kind === "power" || (kind === "microphone" && AudioState.micMuted) || (kind === "volume" && AudioState.muted)
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
			const name = NiriState.osdText || (kind === "usb" ? Config.osd.usbName : Config.osd.screenName)
			return name + (NiriState.osdOn ? Config.osd.plugged : Config.osd.unplugged)
		}
		if (kind === "power")
			return PowerState.plugged ? Config.osd.chargerOn : Config.osd.chargerOff
		if (kind === "brightness")
			return Math.round(amount * 100) + "%"
		if (kind === "microphone")
			return AudioState.micMuted ? Config.osd.micMuted : AudioState.levelText(AudioState.micVolume, false)
		if (AudioState.muted)
			return Config.osd.audioMuted
		return Math.round(amount * 100) + "%"
	}
	readonly property string glyph: {
		if (kind === "usb")
			return Config.icon(Config.osd.usbIcon)
		if (kind === "screen")
			return Config.icon(NiriState.osdOn ? Config.osd.screenOnIcon : Config.osd.screenOffIcon)
		if (kind === "power")
			return Config.icon(PowerState.plugged ? Config.osd.chargerOnIcon : Config.osd.chargerOffIcon)
		if (kind === "brightness")
			return Config.icon(Config.osd.brightnessIcon)
		if (kind === "microphone")
			return AudioState.micGlyph(AudioState.micVolume, AudioState.micMuted)
		return AudioState.volumeGlyph(amount, AudioState.muted || amount <= Config.audio.muteFloor)
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
			implicitWidth: Config.osd.barWidth
			implicitHeight: Config.osd.barHeight
			radius: Config.osd.barHeight / 2
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
			elide: Text.ElideRight
			width: Math.min(caption.advanceWidth, Config.osd.labelWidth)
			anchors.verticalCenter: parent.verticalCenter
		}
	}

	TextMetrics {
		id: caption
		font.family: Theme.fontFamily
		font.pixelSize: Theme.fontSize
		text: root.label
	}
}
