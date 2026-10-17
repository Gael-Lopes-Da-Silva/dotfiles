import QtQuick

Item {
	id: root

	readonly property string kind: NiriState.osdKind
	readonly property real amount: {
		if (kind === "brightness")
			return BrightnessState.level
		if (AudioState.muted)
			return 0
		return AudioState.volume
	}
	readonly property real bar: Math.max(0, Math.min(1, amount))
	readonly property string label: {
		if (kind === "brightness")
			return Math.round(amount * 100) + "%"
		if (AudioState.muted)
			return "Muted"
		return Math.round(amount * 100) + "%"
	}
	readonly property string glyph: {
		if (kind === "brightness")
			return String.fromCodePoint(0xF00DF)
		if (AudioState.muted || amount <= 0.001)
			return String.fromCodePoint(0xF075F)
		if (amount < 0.33)
			return String.fromCodePoint(0xF057F)
		if (amount < 0.66)
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
			font.pixelSize: Theme.fontSize + 6
			anchors.verticalCenter: parent.verticalCenter
		}

		Rectangle {
			implicitWidth: 148
			implicitHeight: 4
			radius: 2
			color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.18)
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
			anchors.verticalCenter: parent.verticalCenter
		}
	}
}
