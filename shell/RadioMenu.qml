import QtQuick
import Quickshell.Bluetooth
import Quickshell.Networking

Item {
	id: root

	readonly property string page: RadioState.menuPage
	readonly property int menuWidth: 320
	readonly property int rowHeight: 44

	implicitWidth: menuWidth
	implicitHeight: column.implicitHeight + Theme.padding
	width: implicitWidth
	height: implicitHeight

	function ink(alpha) {
		return Theme.ink(alpha)
	}

	component Toggle: Item {
		id: toggle

		property bool on: false

		implicitWidth: 38
		implicitHeight: 22

		Rectangle {
			anchors.fill: parent
			radius: height / 2
			color: toggle.on ? Theme.foreground : root.ink(0.16)
		}

		Rectangle {
			width: 16
			height: 16
			radius: 8
			anchors.verticalCenter: parent.verticalCenter
			x: toggle.on ? parent.width - width - 3 : 3
			color: toggle.on ? Theme.background : Theme.foreground
		}
	}

	component VolumeBar: Item {
		id: bar

		property real value: 0
		property real slide: 0
		readonly property real shown: drag.pressed ? slide : value
		signal moved(real amount)

		implicitHeight: 22

		Rectangle {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			height: 5
			radius: 2.5
			color: root.ink(0.16)

			Rectangle {
				width: parent.width * Math.max(0, Math.min(1, bar.shown))
				height: parent.height
				radius: parent.radius
				color: Theme.foreground
			}
		}

		Rectangle {
			width: 14
			height: 14
			radius: 7
			anchors.verticalCenter: parent.verticalCenter
			x: Math.max(0, Math.min(parent.width - width, parent.width * bar.shown - width / 2))
			color: Theme.foreground
		}

		MouseArea {
			id: drag
			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor
			onPressed: mouse => apply(mouse.x)
			onPositionChanged: mouse => {
				if (pressed)
					apply(mouse.x)
			}

			function apply(x) {
				const amount = Math.max(0, Math.min(1, x / width))
				bar.slide = amount
				bar.moved(amount)
			}
		}
	}

	Column {
		id: column
		width: root.menuWidth
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: Theme.padding * 0.5
		spacing: 4

		Item {
			width: parent.width
			height: root.rowHeight
			visible: root.page === "wifi"

			Rectangle {
				anchors.fill: parent
				anchors.leftMargin: 8
				anchors.rightMargin: 8
				radius: 12
				color: root.ink(0.06)
			}

			Text {
				id: wifiHeadIcon
				anchors.left: parent.left
				anchors.leftMargin: 20
				anchors.verticalCenter: parent.verticalCenter
				text: RadioState.wifiGlyph()
				color: Theme.foreground
				font.family: Theme.iconFont
				font.pixelSize: Theme.fontSize + 6
			}

			Text {
				anchors.left: wifiHeadIcon.right
				anchors.leftMargin: Theme.gap
				anchors.verticalCenter: parent.verticalCenter
				text: "Wi-Fi"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize + 1
			}

			Toggle {
				anchors.right: parent.right
				anchors.rightMargin: 18
				anchors.verticalCenter: parent.verticalCenter
				on: Networking.wifiEnabled
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
			color: root.ink(0.45)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			horizontalAlignment: Text.AlignHCenter
			topPadding: 10
			bottomPadding: 8
		}

		Repeater {
			model: root.page === "wifi" ? RadioState.wifiList : []

			Rectangle {
				id: wifiRow
				required property var modelData
				readonly property bool connected: modelData.connected

				width: root.menuWidth - 16
				x: 8
				height: 40
				radius: 10
				color: connected ? root.ink(0.12) : wifiHover.hovered ? root.ink(0.07) : "transparent"

				Rectangle {
					id: wifiWell
					anchors.left: parent.left
					anchors.leftMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					width: 28
					height: 28
					radius: 8
					color: root.ink(0.08)

					Text {
						anchors.centerIn: parent
						text: RadioState.strengthGlyph(wifiRow.modelData.signalStrength || 0)
						color: Theme.foreground
						font.family: Theme.iconFont
						font.pixelSize: Theme.fontSize + 2
					}
				}

				Text {
					id: lock
					anchors.left: wifiWell.right
					anchors.leftMargin: 8
					anchors.verticalCenter: parent.verticalCenter
					visible: RadioState.secured(wifiRow.modelData)
					text: String.fromCodePoint(0xF033E)
					color: root.ink(0.55)
					font.family: Theme.iconFont
					font.pixelSize: Theme.fontSize
				}

				Text {
					id: status
					anchors.right: parent.right
					anchors.rightMargin: 12
					anchors.verticalCenter: parent.verticalCenter
					text: wifiRow.connected ? "Connected" : Math.round((wifiRow.modelData.signalStrength || 0) * 100) + "%"
					color: wifiRow.connected ? Theme.foreground : root.ink(0.5)
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize - 1
				}

				Text {
					anchors.left: lock.visible ? lock.right : wifiWell.right
					anchors.leftMargin: 8
					anchors.right: status.left
					anchors.rightMargin: 8
					anchors.verticalCenter: parent.verticalCenter
					text: wifiRow.modelData.name
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
					elide: Text.ElideRight
				}

				MouseArea {
					id: wifiHover
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: RadioState.activateWifi(wifiRow.modelData)
				}
			}
		}

		Item {
			visible: root.page === "wifi" && RadioState.pending !== null
			width: parent.width
			height: 48

			Rectangle {
				anchors.fill: parent
				anchors.leftMargin: 8
				anchors.rightMargin: 8
				anchors.topMargin: 4
				anchors.bottomMargin: 4
				radius: 10
				color: root.ink(0.08)
			}

			Text {
				anchors.left: parent.left
				anchors.leftMargin: 20
				anchors.verticalCenter: parent.verticalCenter
				text: String.fromCodePoint(0xF033E)
				color: root.ink(0.55)
				font.family: Theme.iconFont
				font.pixelSize: Theme.fontSize + 2
			}

			TextInput {
				id: secret
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: 46
				anchors.rightMargin: 18
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
				color: root.ink(0.4)
				font: secret.font
			}
		}

		Item {
			width: parent.width
			height: root.rowHeight
			visible: root.page === "bluetooth"

			Rectangle {
				anchors.fill: parent
				anchors.leftMargin: 8
				anchors.rightMargin: 8
				radius: 12
				color: root.ink(0.06)
			}

			Text {
				id: btHeadIcon
				anchors.left: parent.left
				anchors.leftMargin: 20
				anchors.verticalCenter: parent.verticalCenter
				text: RadioState.btGlyph()
				color: Theme.foreground
				font.family: Theme.iconFont
				font.pixelSize: Theme.fontSize + 6
			}

			Text {
				anchors.left: btHeadIcon.right
				anchors.leftMargin: Theme.gap
				anchors.verticalCenter: parent.verticalCenter
				text: "Bluetooth"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize + 1
			}

			Toggle {
				anchors.right: parent.right
				anchors.rightMargin: 18
				anchors.verticalCenter: parent.verticalCenter
				on: RadioState.bluetooth && RadioState.bluetooth.enabled
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
			color: root.ink(0.45)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			horizontalAlignment: Text.AlignHCenter
			topPadding: 10
			bottomPadding: 8
		}

		Repeater {
			model: root.page === "bluetooth" ? RadioState.btList : []

			Rectangle {
				id: btRow
				required property var modelData
				readonly property bool connected: modelData.connected

				width: root.menuWidth - 16
				x: 8
				height: 40
				radius: 10
				color: connected ? root.ink(0.12) : btHover.hovered ? root.ink(0.07) : "transparent"

				Rectangle {
					id: btWell
					anchors.left: parent.left
					anchors.leftMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					width: 28
					height: 28
					radius: 8
					color: root.ink(0.08)

					Text {
						anchors.centerIn: parent
						text: btRow.connected ? String.fromCodePoint(0xF00B1) : String.fromCodePoint(0xF00AF)
						color: Theme.foreground
						font.family: Theme.iconFont
						font.pixelSize: Theme.fontSize + 2
					}
				}

				Text {
					id: btStatus
					anchors.right: parent.right
					anchors.rightMargin: 12
					anchors.verticalCenter: parent.verticalCenter
					text: {
						if (btRow.modelData.connected && RadioState.btRssiKnown)
							return Math.round(RadioState.btQuality * 100) + "%"
						if (btRow.modelData.connected)
							return "Connected"
						if (btRow.modelData.paired)
							return "Paired"
						return "Pair"
					}
					color: btRow.connected ? Theme.foreground : root.ink(0.5)
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize - 1
				}

				Text {
					anchors.left: btWell.right
					anchors.leftMargin: 8
					anchors.right: btStatus.left
					anchors.rightMargin: 8
					anchors.verticalCenter: parent.verticalCenter
					text: RadioState.deviceLabel(btRow.modelData)
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
					onClicked: RadioState.activateBt(btRow.modelData)
				}
			}
		}

		Item {
			width: parent.width
			height: root.rowHeight
			visible: root.page === "audio"

			Rectangle {
				anchors.fill: parent
				anchors.leftMargin: 8
				anchors.rightMargin: 8
				radius: 12
				color: root.ink(0.06)
			}

			Text {
				id: audioHeadIcon
				anchors.left: parent.left
				anchors.leftMargin: 20
				anchors.verticalCenter: parent.verticalCenter
				text: AudioState.volumeGlyph(AudioState.sinkLevel, AudioState.sinkMuted)
				color: Theme.foreground
				font.family: Theme.iconFont
				font.pixelSize: Theme.fontSize + 6
			}

			Text {
				anchors.left: audioHeadIcon.right
				anchors.leftMargin: Theme.gap
				anchors.verticalCenter: parent.verticalCenter
				text: "Audio"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize + 1
			}

			Text {
				anchors.right: parent.right
				anchors.rightMargin: 20
				anchors.verticalCenter: parent.verticalCenter
				text: AudioState.levelText(AudioState.sinkLevel, AudioState.sinkMuted)
				color: AudioState.sinkMuted ? root.ink(0.5) : Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: AudioState.toggleMute(AudioState.sink)
			}
		}

		Item {
			visible: root.page === "audio" && AudioState.sink !== null
			width: parent.width
			height: 28

			VolumeBar {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: 20
				anchors.rightMargin: 20
				value: AudioState.sinkLevel
				onMoved: amount => AudioState.setVolume(AudioState.sink, amount)
			}
		}

		Text {
			visible: root.page === "audio" && AudioState.sinkNodes.length > 0
			width: parent.width
			text: "Outputs"
			color: root.ink(0.4)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize - 2
			leftPadding: 20
			topPadding: 8
			bottomPadding: 2
		}

		Text {
			visible: root.page === "audio" && AudioState.sinkNodes.length === 0
			width: parent.width
			text: "No outputs"
			color: root.ink(0.45)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			horizontalAlignment: Text.AlignHCenter
			topPadding: 8
			bottomPadding: 6
		}

		Repeater {
			model: root.page === "audio" ? AudioState.sinkNodes : []

			Rectangle {
				id: sinkRow
				required property var modelData
				readonly property bool active: AudioState.sink && modelData.id === AudioState.sink.id

				width: root.menuWidth - 16
				x: 8
				height: 40
				radius: 10
				color: active ? root.ink(0.12) : sinkHover.hovered ? root.ink(0.07) : "transparent"

				Rectangle {
					id: sinkWell
					anchors.left: parent.left
					anchors.leftMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					width: 28
					height: 28
					radius: 8
					color: root.ink(0.08)

					Text {
						anchors.centerIn: parent
						text: AudioState.volumeGlyph(sinkRow.modelData.audio ? sinkRow.modelData.audio.volume : 0, sinkRow.modelData.audio ? sinkRow.modelData.audio.muted : false)
						color: Theme.foreground
						font.family: Theme.iconFont
						font.pixelSize: Theme.fontSize + 2
					}
				}

				Text {
					id: sinkStatus
					anchors.right: parent.right
					anchors.rightMargin: 12
					anchors.verticalCenter: parent.verticalCenter
					visible: sinkRow.active
					text: "Active"
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize - 1
				}

				Text {
					anchors.left: sinkWell.right
					anchors.leftMargin: 8
					anchors.right: sinkStatus.left
					anchors.rightMargin: 8
					anchors.verticalCenter: parent.verticalCenter
					text: AudioState.nodeLabel(sinkRow.modelData)
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
					elide: Text.ElideRight
				}

				MouseArea {
					id: sinkHover
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: AudioState.selectSink(sinkRow.modelData)
				}
			}
		}

		Text {
			visible: root.page === "audio"
			width: parent.width
			text: "Applications"
			color: root.ink(0.4)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize - 2
			leftPadding: 20
			topPadding: 10
			bottomPadding: 2
		}

		Text {
			visible: root.page === "audio" && AudioState.streamNodes.length === 0
			width: parent.width
			text: "No app audio"
			color: root.ink(0.45)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			horizontalAlignment: Text.AlignHCenter
			topPadding: 6
			bottomPadding: 6
		}

		Repeater {
			model: root.page === "audio" ? AudioState.streamNodes : []

			Item {
				id: streamRow
				required property var modelData
				width: root.menuWidth
				height: 64

				Rectangle {
					id: streamWell
					anchors.left: parent.left
					anchors.leftMargin: 14
					anchors.top: parent.top
					anchors.topMargin: 6
					width: 28
					height: 28
					radius: 8
					color: root.ink(0.08)

					Text {
						anchors.centerIn: parent
						text: AudioState.volumeGlyph(streamRow.modelData.audio ? streamRow.modelData.audio.volume : 0, streamRow.modelData.audio ? streamRow.modelData.audio.muted : false)
						color: Theme.foreground
						font.family: Theme.iconFont
						font.pixelSize: Theme.fontSize + 2
					}
				}

				Text {
					id: streamMute
					anchors.right: parent.right
					anchors.rightMargin: 18
					anchors.verticalCenter: streamWell.verticalCenter
					text: streamRow.modelData.audio && streamRow.modelData.audio.muted ? "Muted" : AudioState.levelText(streamRow.modelData.audio ? streamRow.modelData.audio.volume : 0, false)
					color: streamRow.modelData.audio && streamRow.modelData.audio.muted ? root.ink(0.5) : Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize - 1
				}

				Text {
					anchors.left: streamWell.right
					anchors.leftMargin: 8
					anchors.right: streamMute.left
					anchors.rightMargin: 8
					anchors.verticalCenter: streamWell.verticalCenter
					text: AudioState.streamLabel(streamRow.modelData)
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
					elide: Text.ElideRight
				}

				MouseArea {
					anchors.right: parent.right
					anchors.top: parent.top
					width: streamMute.implicitWidth + 36
					height: 36
					cursorShape: Qt.PointingHandCursor
					onClicked: AudioState.toggleMute(streamRow.modelData)
				}

				VolumeBar {
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.bottom: parent.bottom
					anchors.leftMargin: 20
					anchors.rightMargin: 20
					anchors.bottomMargin: 2
					value: streamRow.modelData.audio ? streamRow.modelData.audio.volume : 0
					onMoved: amount => AudioState.setVolume(streamRow.modelData, amount)
				}
			}
		}

		Item {
			width: parent.width
			height: root.rowHeight
			visible: root.page === "microphone"

			Rectangle {
				anchors.fill: parent
				anchors.leftMargin: 8
				anchors.rightMargin: 8
				radius: 12
				color: root.ink(0.06)
			}

			Text {
				id: micHeadIcon
				anchors.left: parent.left
				anchors.leftMargin: 20
				anchors.verticalCenter: parent.verticalCenter
				text: AudioState.micGlyph(AudioState.sourceMuted)
				color: Theme.foreground
				font.family: Theme.iconFont
				font.pixelSize: Theme.fontSize + 6
			}

			Text {
				anchors.left: micHeadIcon.right
				anchors.leftMargin: Theme.gap
				anchors.verticalCenter: parent.verticalCenter
				text: "Microphone"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize + 1
			}

			Text {
				anchors.right: parent.right
				anchors.rightMargin: 20
				anchors.verticalCenter: parent.verticalCenter
				text: AudioState.source ? AudioState.levelText(AudioState.sourceLevel, AudioState.sourceMuted) : "None"
				color: AudioState.sourceMuted ? root.ink(0.5) : Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
			}

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: AudioState.toggleMute(AudioState.source)
			}
		}

		Item {
			visible: root.page === "microphone" && AudioState.source !== null
			width: parent.width
			height: 28

			VolumeBar {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: 20
				anchors.rightMargin: 20
				value: AudioState.sourceLevel
				onMoved: amount => AudioState.setVolume(AudioState.source, amount)
			}
		}

		Text {
			visible: root.page === "microphone" && AudioState.sourceNodes.length === 0
			width: parent.width
			text: "No microphones"
			color: root.ink(0.45)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			horizontalAlignment: Text.AlignHCenter
			topPadding: 8
			bottomPadding: 6
		}

		Repeater {
			model: root.page === "microphone" ? AudioState.sourceNodes : []

			Rectangle {
				id: sourceRow
				required property var modelData
				readonly property bool active: AudioState.source && modelData.id === AudioState.source.id

				width: root.menuWidth - 16
				x: 8
				height: 40
				radius: 10
				color: active ? root.ink(0.12) : sourceHover.hovered ? root.ink(0.07) : "transparent"

				Rectangle {
					id: sourceWell
					anchors.left: parent.left
					anchors.leftMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					width: 28
					height: 28
					radius: 8
					color: root.ink(0.08)

					Text {
						anchors.centerIn: parent
						text: AudioState.micGlyph(sourceRow.modelData.audio ? sourceRow.modelData.audio.muted : false)
						color: Theme.foreground
						font.family: Theme.iconFont
						font.pixelSize: Theme.fontSize + 2
					}
				}

				Text {
					id: sourceStatus
					anchors.right: parent.right
					anchors.rightMargin: 12
					anchors.verticalCenter: parent.verticalCenter
					visible: sourceRow.active
					text: "Active"
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize - 1
				}

				Text {
					anchors.left: sourceWell.right
					anchors.leftMargin: 8
					anchors.right: sourceStatus.left
					anchors.rightMargin: 8
					anchors.verticalCenter: parent.verticalCenter
					text: AudioState.nodeLabel(sourceRow.modelData)
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
					elide: Text.ElideRight
				}

				MouseArea {
					id: sourceHover
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: AudioState.selectSource(sourceRow.modelData)
				}
			}
		}
	}
}
