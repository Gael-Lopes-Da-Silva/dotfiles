import QtQuick
import Quickshell.Bluetooth
import Quickshell.Networking
import qs
import qs.services

Item {
	id: root

	readonly property string page: RadioState.menuPage
	readonly property int menuWidth: Theme.radioMenuWidth
	readonly property int rowHeight: Theme.rowHeight

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

		implicitWidth: Theme.toggleWidth
		implicitHeight: Theme.toggleHeight

		Rectangle {
			anchors.fill: parent
			radius: height / 2
			color: toggle.on ? Theme.foreground : root.ink(Theme.track)
		}

		Rectangle {
			width: Theme.toggleKnob
			height: Theme.toggleKnob
			radius: Theme.toggleKnob / 2
			anchors.verticalCenter: parent.verticalCenter
			x: toggle.on ? parent.width - width - Theme.toggleInset : Theme.toggleInset
			color: toggle.on ? Theme.background : Theme.foreground
		}
	}

	component VolumeBar: Item {
		id: bar

		property real value: 0
		property real slide: 0
		readonly property real shown: drag.pressed ? slide : value
		signal moved(real amount)

		implicitHeight: Theme.sliderRow

		Rectangle {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.leftMargin: Theme.inset - Theme.headerInset
			anchors.rightMargin: Theme.inset - Theme.headerInset
			anchors.verticalCenter: parent.verticalCenter
			height: Theme.sliderSlot
			radius: Theme.rowRadius
			color: drag.containsMouse || drag.pressed ? root.ink(Theme.hover) : "transparent"
		}

		Rectangle {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			height: Theme.sliderTrack
			radius: Theme.sliderTrack / 2
			color: root.ink(Theme.track)

			Rectangle {
				width: parent.width * Math.max(0, Math.min(1, bar.shown))
				height: parent.height
				radius: parent.radius
				color: Theme.foreground
			}
		}

		Rectangle {
			width: Theme.sliderThumb
			height: Theme.sliderThumb
			radius: Theme.sliderThumb / 2
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
		spacing: Theme.menuSpacing

		Item {
			width: parent.width
			height: root.rowHeight
			visible: root.page === "wifi"

			Rectangle {
				anchors.fill: parent
				anchors.leftMargin: Theme.inset
				anchors.rightMargin: Theme.inset
				radius: Theme.radius
				color: wifiHeadHover.containsMouse ? root.ink(Theme.buttonHover) : root.ink(Theme.wash)
			}

			Text {
				id: wifiHeadIcon
				anchors.left: parent.left
				anchors.leftMargin: Theme.headerInset
				anchors.verticalCenter: parent.verticalCenter
				text: RadioState.wifiGlyph()
				color: Theme.foreground
				font.family: Theme.iconFont
				font.pixelSize: Theme.iconSize
			}

			Text {
				anchors.left: wifiHeadIcon.right
				anchors.leftMargin: Theme.gap
				anchors.verticalCenter: parent.verticalCenter
				text: "Wi-Fi"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.headingSize
			}

			Toggle {
				anchors.right: parent.right
				anchors.rightMargin: Theme.edgeInset
				anchors.verticalCenter: parent.verticalCenter
				on: Networking.wifiEnabled
			}

			MouseArea {
				id: wifiHeadHover
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: RadioState.toggleWifi()
			}
		}

		Text {
			visible: root.page === "wifi" && RadioState.wifiList.length === 0
			width: parent.width
			text: Networking.wifiEnabled ? "No networks" : "Wi-Fi is off"
			color: root.ink(Theme.muted)
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

				width: root.menuWidth - Theme.inset * 2
				x: Theme.inset
				height: Theme.rowInnerHeight
				radius: Theme.rowRadius
				color: wifiHover.containsMouse ? root.ink(connected ? Theme.buttonHover : Theme.hover) : (connected ? root.ink(Theme.selected) : "transparent")

				Rectangle {
					id: wifiWell
					anchors.left: parent.left
					anchors.leftMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					width: Theme.well
					height: Theme.well
					radius: Theme.buttonRadius
					color: root.ink(Theme.wellFill)

					Text {
						anchors.centerIn: parent
						text: RadioState.strengthGlyph(wifiRow.modelData.signalStrength || 0)
						color: Theme.foreground
						font.family: Theme.iconFont
						font.pixelSize: Theme.glyphSize
					}
				}

				Text {
					id: lock
					anchors.left: wifiWell.right
					anchors.leftMargin: Theme.inset
					anchors.verticalCenter: parent.verticalCenter
					visible: RadioState.secured(wifiRow.modelData)
					text: String.fromCodePoint(0xF033E)
					color: root.ink(Theme.iconMute)
					font.family: Theme.iconFont
					font.pixelSize: Theme.fontSize
				}

				Text {
					id: status
					anchors.right: parent.right
					anchors.rightMargin: 12
					anchors.verticalCenter: parent.verticalCenter
					text: wifiRow.connected ? "Connected" : Math.round((wifiRow.modelData.signalStrength || 0) * 100) + "%"
					color: wifiRow.connected ? Theme.foreground : root.ink(Theme.quiet)
					font.family: Theme.fontFamily
					font.pixelSize: Theme.smallSize
				}

				Text {
					anchors.left: lock.visible ? lock.right : wifiWell.right
					anchors.leftMargin: Theme.inset
					anchors.right: status.left
					anchors.rightMargin: Theme.inset
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
				anchors.leftMargin: Theme.inset
				anchors.rightMargin: Theme.inset
				anchors.topMargin: 4
				anchors.bottomMargin: 4
				radius: Theme.rowRadius
				color: secretHover.hovered ? root.ink(Theme.buttonHover) : root.ink(Theme.wellFill)
			}

			HoverHandler {
				id: secretHover
			}

			Text {
				anchors.left: parent.left
				anchors.leftMargin: Theme.headerInset
				anchors.verticalCenter: parent.verticalCenter
				text: String.fromCodePoint(0xF033E)
				color: root.ink(Theme.iconMute)
				font.family: Theme.iconFont
				font.pixelSize: Theme.glyphSize
			}

			TextInput {
				id: secret
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: 46
				anchors.rightMargin: Theme.edgeInset
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
				color: root.ink(Theme.dim)
				font: secret.font
			}
		}

		Item {
			width: parent.width
			height: root.rowHeight
			visible: root.page === "bluetooth"

			Rectangle {
				anchors.fill: parent
				anchors.leftMargin: Theme.inset
				anchors.rightMargin: Theme.inset
				radius: Theme.radius
				color: btHeadHover.containsMouse ? root.ink(Theme.buttonHover) : root.ink(Theme.wash)
			}

			Text {
				id: btHeadIcon
				anchors.left: parent.left
				anchors.leftMargin: Theme.headerInset
				anchors.verticalCenter: parent.verticalCenter
				text: RadioState.btGlyph()
				color: Theme.foreground
				font.family: Theme.iconFont
				font.pixelSize: Theme.iconSize
			}

			Text {
				anchors.left: btHeadIcon.right
				anchors.leftMargin: Theme.gap
				anchors.verticalCenter: parent.verticalCenter
				text: "Bluetooth"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.headingSize
			}

			Toggle {
				anchors.right: parent.right
				anchors.rightMargin: Theme.edgeInset
				anchors.verticalCenter: parent.verticalCenter
				on: RadioState.bluetooth && RadioState.bluetooth.enabled
			}

			MouseArea {
				id: btHeadHover
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: RadioState.toggleBluetooth()
			}
		}

		Text {
			visible: root.page === "bluetooth" && RadioState.btList.length === 0
			width: parent.width
			text: RadioState.bluetooth && RadioState.bluetooth.enabled ? "No devices" : "Bluetooth is off"
			color: root.ink(Theme.muted)
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

				width: root.menuWidth - Theme.inset * 2
				x: Theme.inset
				height: Theme.rowInnerHeight
				radius: Theme.rowRadius
				color: btHover.containsMouse ? root.ink(connected ? Theme.buttonHover : Theme.hover) : (connected ? root.ink(Theme.selected) : "transparent")

				Rectangle {
					id: btWell
					anchors.left: parent.left
					anchors.leftMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					width: Theme.well
					height: Theme.well
					radius: Theme.buttonRadius
					color: root.ink(Theme.wellFill)

					Text {
						anchors.centerIn: parent
						text: btRow.connected ? String.fromCodePoint(0xF00B1) : String.fromCodePoint(0xF00AF)
						color: Theme.foreground
						font.family: Theme.iconFont
						font.pixelSize: Theme.glyphSize
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
					color: btRow.connected ? Theme.foreground : root.ink(Theme.quiet)
					font.family: Theme.fontFamily
					font.pixelSize: Theme.smallSize
				}

				Text {
					anchors.left: btWell.right
					anchors.leftMargin: Theme.inset
					anchors.right: btStatus.left
					anchors.rightMargin: Theme.inset
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
				anchors.leftMargin: Theme.inset
				anchors.rightMargin: Theme.inset
				radius: Theme.radius
				color: audioHeadHover.containsMouse ? root.ink(Theme.buttonHover) : root.ink(Theme.wash)
			}

			Text {
				id: audioHeadIcon
				anchors.left: parent.left
				anchors.leftMargin: Theme.headerInset
				anchors.verticalCenter: parent.verticalCenter
				text: AudioState.volumeGlyph(AudioState.sinkLevel, AudioState.sinkMuted)
				color: Theme.foreground
				font.family: Theme.iconFont
				font.pixelSize: Theme.iconSize
			}

			Text {
				anchors.left: audioHeadIcon.right
				anchors.leftMargin: Theme.gap
				anchors.verticalCenter: parent.verticalCenter
				text: "Audio"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.headingSize
			}

			Text {
				anchors.right: parent.right
				anchors.rightMargin: Theme.headerInset
				anchors.verticalCenter: parent.verticalCenter
				text: AudioState.levelText(AudioState.sinkLevel, AudioState.sinkMuted)
				color: AudioState.sinkMuted ? root.ink(Theme.quiet) : Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
			}

			MouseArea {
				id: audioHeadHover
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: AudioState.toggleMute(AudioState.sink)
			}
		}

		Item {
			visible: root.page === "audio" && AudioState.sink !== null
			width: parent.width
			height: Theme.sliderSlot

			VolumeBar {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: Theme.headerInset
				anchors.rightMargin: Theme.headerInset
				value: AudioState.sinkLevel
				onMoved: amount => AudioState.setVolume(AudioState.sink, amount)
			}
		}

		Text {
			visible: root.page === "audio" && AudioState.sinkNodes.length > 0
			width: parent.width
			text: "Outputs"
			color: root.ink(Theme.dim)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.labelSize
			leftPadding: Theme.headerInset
			topPadding: 8
			bottomPadding: 2
		}

		Text {
			visible: root.page === "audio" && AudioState.sinkNodes.length === 0
			width: parent.width
			text: "No outputs"
			color: root.ink(Theme.muted)
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

				width: root.menuWidth - Theme.inset * 2
				x: Theme.inset
				height: Theme.rowInnerHeight
				radius: Theme.rowRadius
				color: sinkHover.containsMouse ? root.ink(active ? Theme.buttonHover : Theme.hover) : (active ? root.ink(Theme.selected) : "transparent")

				Rectangle {
					id: sinkWell
					anchors.left: parent.left
					anchors.leftMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					width: Theme.well
					height: Theme.well
					radius: Theme.buttonRadius
					color: root.ink(Theme.wellFill)

					Text {
						anchors.centerIn: parent
						text: AudioState.volumeGlyph(sinkRow.modelData.audio ? sinkRow.modelData.audio.volume : 0, sinkRow.modelData.audio ? sinkRow.modelData.audio.muted : false)
						color: Theme.foreground
						font.family: Theme.iconFont
						font.pixelSize: Theme.glyphSize
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
					font.pixelSize: Theme.smallSize
				}

				Text {
					anchors.left: sinkWell.right
					anchors.leftMargin: Theme.inset
					anchors.right: sinkStatus.left
					anchors.rightMargin: Theme.inset
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
			color: root.ink(Theme.dim)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.labelSize
			leftPadding: Theme.headerInset
			topPadding: 10
			bottomPadding: 2
		}

		Text {
			visible: root.page === "audio" && AudioState.streamNodes.length === 0
			width: parent.width
			text: "No applications"
			color: root.ink(Theme.muted)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			horizontalAlignment: Text.AlignHCenter
			topPadding: 6
			bottomPadding: 6
		}

		Repeater {
			model: root.page === "audio" ? AudioState.streamNodes : []

			Column {
				id: streamRow
				required property var modelData
				width: root.menuWidth
				spacing: Theme.menuSpacing

				Item {
					width: parent.width
					height: root.rowHeight

					Rectangle {
						anchors.fill: parent
						anchors.leftMargin: Theme.inset
						anchors.rightMargin: Theme.inset
						radius: Theme.radius
						color: streamMuteHit.containsMouse ? root.ink(Theme.buttonHover) : root.ink(Theme.wash)
					}

					Text {
						id: streamIcon
						anchors.left: parent.left
						anchors.leftMargin: Theme.headerInset
						anchors.verticalCenter: parent.verticalCenter
						text: AudioState.volumeGlyph(streamRow.modelData.audio ? streamRow.modelData.audio.volume : 0, streamRow.modelData.audio ? streamRow.modelData.audio.muted : false)
						color: Theme.foreground
						font.family: Theme.iconFont
						font.pixelSize: Theme.iconSize
					}

					Text {
						anchors.left: streamIcon.right
						anchors.leftMargin: Theme.gap
						anchors.right: streamLevel.left
						anchors.rightMargin: Theme.gap
						anchors.verticalCenter: parent.verticalCenter
						text: AudioState.streamLabel(streamRow.modelData)
						color: Theme.foreground
						font.family: Theme.fontFamily
						font.pixelSize: Theme.headingSize
						elide: Text.ElideRight
					}

					Text {
						id: streamLevel
						anchors.right: parent.right
						anchors.rightMargin: Theme.headerInset
						anchors.verticalCenter: parent.verticalCenter
						text: AudioState.levelText(streamRow.modelData.audio ? streamRow.modelData.audio.volume : 0, streamRow.modelData.audio ? streamRow.modelData.audio.muted : false)
						color: streamRow.modelData.audio && streamRow.modelData.audio.muted ? root.ink(Theme.quiet) : Theme.foreground
						font.family: Theme.fontFamily
						font.pixelSize: Theme.fontSize
					}

					MouseArea {
						id: streamMuteHit
						anchors.fill: parent
						hoverEnabled: true
						cursorShape: Qt.PointingHandCursor
						onClicked: AudioState.toggleMute(streamRow.modelData)
					}
				}

				Item {
					width: parent.width
					height: Theme.sliderSlot

					VolumeBar {
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						anchors.leftMargin: Theme.headerInset
						anchors.rightMargin: Theme.headerInset
						value: streamRow.modelData.audio ? streamRow.modelData.audio.volume : 0
						onMoved: amount => AudioState.setVolume(streamRow.modelData, amount)
					}
				}
			}
		}

		Item {
			width: parent.width
			height: root.rowHeight
			visible: root.page === "microphone"

			Rectangle {
				anchors.fill: parent
				anchors.leftMargin: Theme.inset
				anchors.rightMargin: Theme.inset
				radius: Theme.radius
				color: micHeadHover.containsMouse ? root.ink(Theme.buttonHover) : root.ink(Theme.wash)
			}

			Text {
				id: micHeadIcon
				anchors.left: parent.left
				anchors.leftMargin: Theme.headerInset
				anchors.verticalCenter: parent.verticalCenter
				text: AudioState.micGlyph(AudioState.sourceLevel, AudioState.sourceMuted)
				color: Theme.foreground
				font.family: Theme.iconFont
				font.pixelSize: Theme.iconSize
			}

			Text {
				anchors.left: micHeadIcon.right
				anchors.leftMargin: Theme.gap
				anchors.verticalCenter: parent.verticalCenter
				text: "Microphone"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.headingSize
			}

			Text {
				anchors.right: parent.right
				anchors.rightMargin: Theme.headerInset
				anchors.verticalCenter: parent.verticalCenter
				text: AudioState.source ? AudioState.levelText(AudioState.sourceLevel, AudioState.sourceMuted) : "None"
				color: AudioState.sourceMuted ? root.ink(Theme.quiet) : Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
			}

			MouseArea {
				id: micHeadHover
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: AudioState.toggleMute(AudioState.source)
			}
		}

		Item {
			visible: root.page === "microphone" && AudioState.source !== null
			width: parent.width
			height: Theme.sliderSlot

			VolumeBar {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: Theme.headerInset
				anchors.rightMargin: Theme.headerInset
				value: AudioState.sourceLevel
				onMoved: amount => AudioState.setVolume(AudioState.source, amount)
			}
		}

		Text {
			visible: root.page === "microphone" && AudioState.sourceNodes.length > 0
			width: parent.width
			text: "Inputs"
			color: root.ink(Theme.dim)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.labelSize
			leftPadding: Theme.headerInset
			topPadding: 8
			bottomPadding: 2
		}

		Text {
			visible: root.page === "microphone" && AudioState.sourceNodes.length === 0
			width: parent.width
			text: "No microphones"
			color: root.ink(Theme.muted)
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

				width: root.menuWidth - Theme.inset * 2
				x: Theme.inset
				height: Theme.rowInnerHeight
				radius: Theme.rowRadius
				color: sourceHover.containsMouse ? root.ink(active ? Theme.buttonHover : Theme.hover) : (active ? root.ink(Theme.selected) : "transparent")

				Rectangle {
					id: sourceWell
					anchors.left: parent.left
					anchors.leftMargin: 6
					anchors.verticalCenter: parent.verticalCenter
					width: Theme.well
					height: Theme.well
					radius: Theme.buttonRadius
					color: root.ink(Theme.wellFill)

					Text {
						anchors.centerIn: parent
						text: AudioState.micGlyph(sourceRow.modelData.audio ? sourceRow.modelData.audio.volume : 0, sourceRow.modelData.audio ? sourceRow.modelData.audio.muted : false)
						color: Theme.foreground
						font.family: Theme.iconFont
						font.pixelSize: Theme.glyphSize
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
					font.pixelSize: Theme.smallSize
				}

				Text {
					anchors.left: sourceWell.right
					anchors.leftMargin: Theme.inset
					anchors.right: sourceStatus.left
					anchors.rightMargin: Theme.inset
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

		Text {
			visible: root.page === "microphone"
			width: parent.width
			text: "Applications"
			color: root.ink(Theme.dim)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.labelSize
			leftPadding: Theme.headerInset
			topPadding: 10
			bottomPadding: 2
		}

		Text {
			visible: root.page === "microphone" && AudioState.captureNodes.length === 0
			width: parent.width
			text: "No applications"
			color: root.ink(Theme.muted)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			horizontalAlignment: Text.AlignHCenter
			topPadding: 6
			bottomPadding: 6
		}

		Repeater {
			model: root.page === "microphone" ? AudioState.captureNodes : []

			Column {
				id: captureRow
				required property var modelData
				width: root.menuWidth
				spacing: Theme.menuSpacing

				Item {
					width: parent.width
					height: root.rowHeight

					Rectangle {
						anchors.fill: parent
						anchors.leftMargin: Theme.inset
						anchors.rightMargin: Theme.inset
						radius: Theme.radius
						color: captureMuteHit.containsMouse ? root.ink(Theme.buttonHover) : root.ink(Theme.wash)
					}

					Text {
						id: captureIcon
						anchors.left: parent.left
						anchors.leftMargin: Theme.headerInset
						anchors.verticalCenter: parent.verticalCenter
						text: AudioState.micGlyph(captureRow.modelData.audio ? captureRow.modelData.audio.volume : 0, captureRow.modelData.audio ? captureRow.modelData.audio.muted : false)
						color: Theme.foreground
						font.family: Theme.iconFont
						font.pixelSize: Theme.iconSize
					}

					Text {
						anchors.left: captureIcon.right
						anchors.leftMargin: Theme.gap
						anchors.right: captureLevel.left
						anchors.rightMargin: Theme.gap
						anchors.verticalCenter: parent.verticalCenter
						text: AudioState.streamLabel(captureRow.modelData)
						color: Theme.foreground
						font.family: Theme.fontFamily
						font.pixelSize: Theme.headingSize
						elide: Text.ElideRight
					}

					Text {
						id: captureLevel
						anchors.right: parent.right
						anchors.rightMargin: Theme.headerInset
						anchors.verticalCenter: parent.verticalCenter
						text: AudioState.levelText(captureRow.modelData.audio ? captureRow.modelData.audio.volume : 0, captureRow.modelData.audio ? captureRow.modelData.audio.muted : false)
						color: captureRow.modelData.audio && captureRow.modelData.audio.muted ? root.ink(Theme.quiet) : Theme.foreground
						font.family: Theme.fontFamily
						font.pixelSize: Theme.fontSize
					}

					MouseArea {
						id: captureMuteHit
						anchors.fill: parent
						hoverEnabled: true
						cursorShape: Qt.PointingHandCursor
						onClicked: AudioState.toggleMute(captureRow.modelData)
					}
				}

				Item {
					width: parent.width
					height: Theme.sliderSlot

					VolumeBar {
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						anchors.leftMargin: Theme.headerInset
						anchors.rightMargin: Theme.headerInset
						value: captureRow.modelData.audio ? captureRow.modelData.audio.volume : 0
						onMoved: amount => AudioState.setVolume(captureRow.modelData, amount)
					}
				}
			}
		}
	}
}
