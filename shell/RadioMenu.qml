import QtQuick
import Quickshell.Bluetooth
import Quickshell.Networking

Item {
	id: root

	readonly property string page: RadioState.menuPage
	readonly property int menuWidth: 300
	readonly property int rowHeight: 36

	implicitWidth: menuWidth
	implicitHeight: column.implicitHeight + Theme.padding
	width: implicitWidth
	height: implicitHeight

	function dim() {
		const color = Theme.foreground
		return Qt.rgba(color.r, color.g, color.b, 0.55)
	}

	Column {
		id: column
		width: root.menuWidth
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: Theme.padding * 0.5
		spacing: 2

		Item {
			width: parent.width
			height: root.rowHeight
			visible: root.page === "wifi"

			Text {
				id: wifiHeadIcon
				anchors.left: parent.left
				anchors.leftMargin: Theme.padding
				anchors.verticalCenter: parent.verticalCenter
				text: RadioState.wifiGlyph()
				color: Theme.foreground
				font.family: Theme.iconFont
				font.pixelSize: Theme.fontSize + 4
			}

			Text {
				anchors.left: wifiHeadIcon.right
				anchors.leftMargin: Theme.gap
				anchors.verticalCenter: parent.verticalCenter
				text: "Wi-Fi"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
			}

			Text {
				anchors.right: parent.right
				anchors.rightMargin: Theme.padding
				anchors.verticalCenter: parent.verticalCenter
				text: Networking.wifiEnabled ? "On" : "Off"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: RadioState.toggleWifi()
			}
		}

		Text {
			visible: root.page === "wifi" && RadioState.wifiList.length === 0
			width: parent.width
			text: Networking.wifiEnabled ? "No networks" : "Wi-Fi is off"
			color: root.dim()
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			leftPadding: Theme.padding
			rightPadding: Theme.padding
			topPadding: 6
			bottomPadding: 6
		}

		Repeater {
			model: root.page === "wifi" ? RadioState.wifiList : []

			Rectangle {
				required property var modelData
				width: root.menuWidth
				height: root.rowHeight
				radius: 8
				color: hover.hovered ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

				Text {
					id: bars
					anchors.left: parent.left
					anchors.leftMargin: Theme.padding
					anchors.verticalCenter: parent.verticalCenter
					text: RadioState.strengthGlyph(modelData.signalStrength || 0)
					color: Theme.foreground
					font.family: Theme.iconFont
					font.pixelSize: Theme.fontSize + 2
				}

				Text {
					id: lock
					anchors.left: bars.right
					anchors.leftMargin: Theme.gap
					anchors.verticalCenter: parent.verticalCenter
					visible: RadioState.secured(modelData)
					text: String.fromCodePoint(0xF033E)
					color: root.dim()
					font.family: Theme.iconFont
					font.pixelSize: Theme.fontSize
				}

				Text {
					id: status
					anchors.right: parent.right
					anchors.rightMargin: Theme.padding
					anchors.verticalCenter: parent.verticalCenter
					text: modelData.connected ? "Connected" : Math.round((modelData.signalStrength || 0) * 100) + "%"
					color: root.dim()
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
				}

				Text {
					anchors.left: lock.visible ? lock.right : bars.right
					anchors.leftMargin: Theme.gap
					anchors.right: status.left
					anchors.rightMargin: Theme.gap
					anchors.verticalCenter: parent.verticalCenter
					text: modelData.name
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
					elide: Text.ElideRight
				}

				MouseArea {
					id: hover
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: RadioState.activateWifi(modelData)
				}
			}
		}

		Item {
			visible: root.page === "wifi" && RadioState.pending !== null
			width: parent.width
			height: secret.implicitHeight + 16

			TextInput {
				id: secret
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: Theme.padding
				anchors.rightMargin: Theme.padding
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
				echoMode: TextInput.Password
				selectByMouse: true
				clip: true
				text: RadioState.password
				onTextChanged: RadioState.password = text
				onVisibleChanged: if (visible) forceActiveFocus()

				Keys.onReturnPressed: event => {
					RadioState.submitPassword()
					event.accepted = true
				}
				Keys.onEnterPressed: event => {
					RadioState.submitPassword()
					event.accepted = true
				}
				Keys.onEscapePressed: event => {
					RadioState.pending = null
					event.accepted = true
				}
			}

			Text {
				anchors.left: secret.left
				anchors.verticalCenter: secret.verticalCenter
				text: "Password"
				visible: secret.text.length === 0
				color: root.dim()
				font: secret.font
			}
		}

		Item {
			width: parent.width
			height: root.rowHeight
			visible: root.page === "bluetooth"

			Text {
				id: btHeadIcon
				anchors.left: parent.left
				anchors.leftMargin: Theme.padding
				anchors.verticalCenter: parent.verticalCenter
				text: RadioState.btGlyph()
				color: Theme.foreground
				font.family: Theme.iconFont
				font.pixelSize: Theme.fontSize + 4
			}

			Text {
				anchors.left: btHeadIcon.right
				anchors.leftMargin: Theme.gap
				anchors.verticalCenter: parent.verticalCenter
				text: "Bluetooth"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
			}

			Text {
				anchors.right: parent.right
				anchors.rightMargin: Theme.padding
				anchors.verticalCenter: parent.verticalCenter
				text: RadioState.bluetooth && RadioState.bluetooth.enabled ? "On" : "Off"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: RadioState.toggleBluetooth()
			}
		}

		Text {
			visible: root.page === "bluetooth" && RadioState.btList.length === 0
			width: parent.width
			text: RadioState.bluetooth && RadioState.bluetooth.enabled ? "No devices" : "Bluetooth is off"
			color: root.dim()
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			leftPadding: Theme.padding
			rightPadding: Theme.padding
			topPadding: 6
			bottomPadding: 6
		}

		Repeater {
			model: root.page === "bluetooth" ? RadioState.btList : []

			Rectangle {
				required property var modelData
				width: root.menuWidth
				height: root.rowHeight
				radius: 8
				color: btHover.hovered ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

				Text {
					id: btMark
					anchors.left: parent.left
					anchors.leftMargin: Theme.padding
					anchors.verticalCenter: parent.verticalCenter
					text: modelData.connected ? String.fromCodePoint(0xF00B1) : String.fromCodePoint(0xF00AF)
					color: Theme.foreground
					font.family: Theme.iconFont
					font.pixelSize: Theme.fontSize + 2
				}

				Text {
					id: btStatus
					anchors.right: parent.right
					anchors.rightMargin: Theme.padding
					anchors.verticalCenter: parent.verticalCenter
					text: {
						if (modelData.connected && RadioState.btRssiKnown)
							return Math.round(RadioState.btQuality * 100) + "%"
						if (modelData.connected)
							return "Connected"
						if (modelData.paired)
							return "Paired"
						return "Pair"
					}
					color: root.dim()
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
				}

				Text {
					anchors.left: btMark.right
					anchors.leftMargin: Theme.gap
					anchors.right: btStatus.left
					anchors.rightMargin: Theme.gap
					anchors.verticalCenter: parent.verticalCenter
					text: RadioState.deviceLabel(modelData)
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
					elide: Text.ElideRight
				}

				MouseArea {
					id: btHover
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: RadioState.activateBt(modelData)
				}
			}
		}
	}
}
