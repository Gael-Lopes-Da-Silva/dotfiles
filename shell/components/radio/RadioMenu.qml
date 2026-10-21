// Menu above the radio chip. Hosts the Wi-Fi, Bluetooth, audio, and microphone pages.
import QtQuick
import qs.lib

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

		Loader {
			id: wifiPage
			width: parent.width
			active: root.page === "wifi"
			asynchronous: false
			height: item ? item.implicitHeight : 0

			sourceComponent: Component {
				WifiPage {
					width: wifiPage.width
					page: root.page
					room: root.room
					live: root.live
				}
			}
		}

		Loader {
			id: bluetoothPage
			width: parent.width
			active: root.page === "bluetooth"
			asynchronous: false
			height: item ? item.implicitHeight : 0

			sourceComponent: Component {
				BluetoothPage {
					width: bluetoothPage.width
					page: root.page
					room: root.room
					live: root.live
				}
			}
		}

		Loader {
			id: audioPage
			width: parent.width
			active: root.page === "audio" || root.page === "microphone"
			asynchronous: false
			height: item ? item.implicitHeight : 0

			sourceComponent: Component {
				AudioPage {
					width: audioPage.width
					page: root.page
					room: root.room
				}
			}
		}
	}
}
