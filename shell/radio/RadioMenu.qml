// Menu above the radio chip. Hosts the Wi-Fi, Bluetooth, audio, and microphone pages.
import QtQuick
import qs.audio
import qs.settings

Item {
	id: root

	property string page: ""
	property bool live: true
	property real room: 4096

	implicitWidth: Config.radio.menuWidth
	implicitHeight: Math.min(room, column.implicitHeight + Theme.padding)
	width: implicitWidth
	height: implicitHeight
	clip: true

	Column {
		id: column
		width: parent.width
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: Theme.padding * 0.5
		spacing: 0

		WifiPage {
			width: parent.width
			page: root.page
			room: root.room
			live: root.live
			visible: root.page === "wifi"
		}

		BluetoothPage {
			width: parent.width
			page: root.page
			room: root.room
			live: root.live
			visible: root.page === "bluetooth"
		}

		AudioPage {
			width: parent.width
			room: root.room
			page: root.page
			visible: root.page === "audio" || root.page === "microphone"
		}
	}
}
