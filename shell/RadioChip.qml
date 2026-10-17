import QtQuick
import Quickshell.Bluetooth
import Quickshell.Networking

Item {
	id: root

	signal picked(string page)

	implicitWidth: row.implicitWidth + Theme.padding * 2
	implicitHeight: row.implicitHeight + Theme.padding * 2
	width: implicitWidth
	height: implicitHeight

	function tone(enabled, quality) {
		const color = Theme.foreground
		if (!enabled)
			return Qt.rgba(color.r, color.g, color.b, 0.4)
		return Qt.rgba(color.r, color.g, color.b, Math.max(0.55, quality))
	}

	Row {
		id: row
		anchors.centerIn: parent
		spacing: Theme.gap

		Item {
			implicitWidth: wifiIcon.implicitWidth + Theme.padding
			implicitHeight: wifiIcon.implicitHeight + Theme.padding
			width: implicitWidth
			height: implicitHeight

			Rectangle {
				anchors.fill: parent
				radius: 8
				color: RadioState.menuPage === "wifi" ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
			}

			Text {
				id: wifiIcon
				anchors.centerIn: parent
				text: RadioState.wifiGlyph()
				color: root.tone(Networking.wifiEnabled, RadioState.activeWifi ? Math.max(0.55, RadioState.wifiSignal) : 0.8)
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
			implicitWidth: btIcon.implicitWidth + Theme.padding
			implicitHeight: btIcon.implicitHeight + Theme.padding
			width: implicitWidth
			height: implicitHeight

			Rectangle {
				anchors.fill: parent
				radius: 8
				color: RadioState.menuPage === "bluetooth" ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
			}

			Text {
				id: btIcon
				anchors.centerIn: parent
				text: RadioState.btGlyph()
				color: root.tone(RadioState.bluetooth && RadioState.bluetooth.enabled, RadioState.connectedBt ? RadioState.btQuality : 0.8)
				font.family: Theme.iconFont
				font.pixelSize: Theme.clockSize
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: root.picked("bluetooth")
			}
		}
	}
}
