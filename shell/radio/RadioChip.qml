import QtQuick
import Quickshell.Bluetooth
import Quickshell.Networking
import qs.settings
import qs.services

Item {
	id: root

	signal picked(string page)
	property string openPage: ""

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
				color: {
					if (wifiHover.containsMouse)
						return Theme.ink(root.openPage === "wifi" ? Theme.buttonHover : Theme.hover)
					return root.openPage === "wifi" ? Theme.ink(Theme.selected) : "transparent"
				}
			}

			Text {
				id: wifiIcon
				anchors.centerIn: parent
				text: RadioState.linkGlyph()
				color: root.tone(RadioState.wired !== null || Networking.wifiEnabled, RadioState.wired !== null ? 1 : (RadioState.activeWifi ? Math.max(Theme.signalFloor, RadioState.wifiSignal) : Theme.signalIdle))
				font.family: Theme.iconFont
				font.pixelSize: Theme.clockSize
			}

			MouseArea {
				id: wifiHover
				anchors.fill: parent
				hoverEnabled: true
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
				color: {
					if (btHover.containsMouse)
						return Theme.ink(root.openPage === "bluetooth" ? Theme.buttonHover : Theme.hover)
					return root.openPage === "bluetooth" ? Theme.ink(Theme.selected) : "transparent"
				}
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
				id: btHover
				anchors.fill: parent
				hoverEnabled: true
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
				color: {
					if (audioHover.containsMouse)
						return Theme.ink(root.openPage === "audio" ? Theme.buttonHover : Theme.hover)
					return root.openPage === "audio" ? Theme.ink(Theme.selected) : "transparent"
				}
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
				id: audioHover
				anchors.fill: parent
				hoverEnabled: true
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
				color: {
					if (micHover.containsMouse)
						return Theme.ink(root.openPage === "microphone" ? Theme.buttonHover : Theme.hover)
					return root.openPage === "microphone" ? Theme.ink(Theme.selected) : "transparent"
				}
			}

			Text {
				id: micIcon
				anchors.centerIn: parent
				text: AudioState.micGlyph(AudioState.sourceLevel, AudioState.sourceMuted)
				color: root.tone(!AudioState.sourceMuted && AudioState.source !== null, 1)
				font.family: Theme.iconFont
				font.pixelSize: Theme.clockSize
			}

			MouseArea {
				id: micHover
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: root.picked("microphone")
			}
		}
	}
}
