import QtQuick
import Quickshell.Bluetooth
import Quickshell.Networking
import qs
import qs.services

Item {
	id: root

	signal picked(string page)

	implicitWidth: row.implicitWidth + Theme.padding * 2
	implicitHeight: row.implicitHeight + Theme.padding * 2
	width: implicitWidth
	height: implicitHeight

	readonly property real buttonSize: {
		const side = Math.max(
			wifiIcon.implicitWidth, wifiIcon.implicitHeight,
			btIcon.implicitWidth, btIcon.implicitHeight,
			audioIcon.implicitWidth, audioIcon.implicitHeight,
			micIcon.implicitWidth, micIcon.implicitHeight
		)
		return side + Theme.padding
	}

	function tone(enabled, quality) {
		const color = Theme.foreground
		if (!enabled)
			return Qt.rgba(color.r, color.g, color.b, Theme.dim)
		return Qt.rgba(color.r, color.g, color.b, Math.max(Theme.signalFloor, quality))
	}

	Row {
		id: row
		anchors.centerIn: parent
		spacing: Theme.gap

		Item {
			implicitWidth: root.buttonSize
			implicitHeight: root.buttonSize
			width: implicitWidth
			height: implicitHeight

			Rectangle {
				anchors.fill: parent
				radius: Theme.buttonRadius
				color: RadioState.menuPage === "wifi" ? Theme.ink(Theme.selected) : "transparent"
			}

			Text {
				id: wifiIcon
				anchors.centerIn: parent
				text: RadioState.wifiGlyph()
				color: root.tone(Networking.wifiEnabled, RadioState.activeWifi ? Math.max(Theme.signalFloor, RadioState.wifiSignal) : Theme.signalIdle)
				font.family: Theme.iconFont
				font.pixelSize: Theme.clockSize
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: root.picked("wifi")
			}
		}

		Item {
			implicitWidth: root.buttonSize
			implicitHeight: root.buttonSize
			width: implicitWidth
			height: implicitHeight

			Rectangle {
				anchors.fill: parent
				radius: Theme.buttonRadius
				color: RadioState.menuPage === "bluetooth" ? Theme.ink(Theme.selected) : "transparent"
			}

			Text {
				id: btIcon
				anchors.centerIn: parent
				text: RadioState.btGlyph()
				color: root.tone(RadioState.bluetooth && RadioState.bluetooth.enabled, RadioState.connectedBt ? RadioState.btQuality : Theme.signalIdle)
				font.family: Theme.iconFont
				font.pixelSize: Theme.clockSize
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: root.picked("bluetooth")
			}
		}

		Item {
			implicitWidth: root.buttonSize
			implicitHeight: root.buttonSize
			width: implicitWidth
			height: implicitHeight

			Rectangle {
				anchors.fill: parent
				radius: Theme.buttonRadius
				color: RadioState.menuPage === "audio" ? Theme.ink(Theme.selected) : "transparent"
			}

			Text {
				id: audioIcon
				anchors.centerIn: parent
				text: AudioState.volumeGlyph(AudioState.sinkLevel, AudioState.sinkMuted)
				color: root.tone(!AudioState.sinkMuted, 1)
				font.family: Theme.iconFont
				font.pixelSize: Theme.clockSize
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: root.picked("audio")
			}
		}

		Item {
			implicitWidth: root.buttonSize
			implicitHeight: root.buttonSize
			width: implicitWidth
			height: implicitHeight

			Rectangle {
				anchors.fill: parent
				radius: Theme.buttonRadius
				color: RadioState.menuPage === "microphone" ? Theme.ink(Theme.selected) : "transparent"
			}

			Text {
				id: micIcon
				anchors.centerIn: parent
				text: AudioState.micGlyph(AudioState.sourceMuted)
				color: root.tone(!AudioState.sourceMuted && AudioState.source !== null, 1)
				font.family: Theme.iconFont
				font.pixelSize: Theme.clockSize
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: root.picked("microphone")
			}
		}
	}
}
