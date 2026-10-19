import QtQuick
import Quickshell.Bluetooth
import Quickshell.Networking
import qs.settings
import qs.services

Item {
	id: root

	readonly property string page: RadioState.menuPage
	readonly property int menuWidth: Theme.radioMenuWidth
	readonly property int rowHeight: Theme.rowHeight
	property real room: 4096

	implicitWidth: menuWidth
	implicitHeight: Math.min(room, column.implicitHeight + Theme.padding)
	width: implicitWidth
	height: implicitHeight
	clip: true

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
			preventStealing: true
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

		Column {
			id: body
			width: parent.width
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

			Item {
				visible: root.page === "wifi" && RadioState.wired !== null
				width: parent.width
				implicitHeight: ethernetBox.implicitHeight
				height: implicitHeight

				Rectangle {
					id: ethernetBox
					width: root.menuWidth - Theme.inset * 2
					x: Theme.inset
					implicitHeight: Math.max(Theme.rowInnerHeight, ethernetCopy.implicitHeight + 12)
					height: implicitHeight
					radius: Theme.rowRadius
					color: root.ink(Theme.selected)

					Rectangle {
						id: ethernetWell
						anchors.left: parent.left
						anchors.leftMargin: 6
						anchors.verticalCenter: parent.verticalCenter
						width: Theme.well
						height: Theme.well
						radius: Theme.buttonRadius
						color: root.ink(Theme.wellFill)

						Text {
							anchors.centerIn: parent
							text: Config.icon(Config.ethernet)
							color: Theme.foreground
							font.family: Theme.iconFont
							font.pixelSize: Theme.glyphSize
						}
					}

					Column {
						id: ethernetCopy
						anchors.left: ethernetWell.right
						anchors.leftMargin: Theme.inset
						anchors.right: parent.right
						anchors.rightMargin: 12
						anchors.verticalCenter: parent.verticalCenter
						spacing: 1

						Text {
							width: parent.width
							text: RadioState.ethernetName()
							color: Theme.foreground
							font.family: Theme.fontFamily
							font.pixelSize: Theme.fontSize
							elide: Text.ElideRight
						}

						Text {
							width: parent.width
							visible: text !== ""
							text: RadioState.ethernetFacts()
							color: root.ink(Theme.quiet)
							font.family: Theme.fontFamily
							font.pixelSize: Theme.smallSize
							elide: Text.ElideRight
						}
					}
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

		}

		Item {
			id: radioPane
			readonly property var radioModel: {
				if (root.page === "wifi")
					return RadioState.wifiList
				if (root.page === "bluetooth")
					return RadioState.btList
				return []
			}
			readonly property real rowBlock: Theme.rowInnerHeight
			readonly property real full: radioColumn.implicitHeight
			readonly property real tail: secretRow.visible ? secretRow.height + column.spacing : 0
			readonly property real budget: Math.max(0, root.room - Theme.padding - body.implicitHeight - column.spacing - tail)
			visible: radioModel.length > 0
			width: parent.width
			implicitHeight: Math.min(full, Math.max(budget, Math.min(full, rowBlock)))
			height: implicitHeight

			property string scrollPage: root.page
			onScrollPageChanged: radioFlick.contentY = 0

			Flickable {
				id: radioFlick
				anchors.fill: parent
				contentWidth: width
				contentHeight: radioColumn.implicitHeight
				clip: true
				boundsBehavior: Flickable.StopAtBounds
				flickableDirection: Flickable.VerticalFlick
				interactive: contentHeight > height + 1

				Column {
					id: radioColumn
					width: radioFlick.width
					spacing: Theme.menuSpacing

					Repeater {
						model: root.page === "wifi" ? radioPane.radioModel : []

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
								text: Config.icon(Config.lock)
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

					Repeater {
						model: root.page === "bluetooth" ? radioPane.radioModel : []

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
									text: Config.icon(btRow.connected ? Config.btOn : Config.btIdle)
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
				}
			}

			Item {
				id: radioScroll
				visible: radioFlick.contentHeight > radioFlick.height + 1
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.right: parent.right
				width: Theme.inset + Theme.noticeProgress

				Rectangle {
					id: radioThumb
					width: Theme.noticeProgress
					radius: width / 2
					anchors.horizontalCenter: parent.horizontalCenter
					color: radioScrollDrag.containsMouse || radioScrollDrag.pressed ? Theme.foreground : root.ink(Theme.scroll)
					height: Math.max(24, radioFlick.height * radioFlick.height / Math.max(radioFlick.contentHeight, 1))
					y: radioFlick.contentY / Math.max(1, radioFlick.contentHeight - radioFlick.height) * Math.max(0, radioFlick.height - height)
				}

				MouseArea {
					id: radioScrollDrag
					anchors.fill: parent
					hoverEnabled: true
					preventStealing: true
					cursorShape: Qt.PointingHandCursor
					property real origin: 0
					property real originY: 0

					function scrollTo(local) {
						const track = Math.max(1, radioFlick.height - radioThumb.height)
						const span = Math.max(0, radioFlick.contentHeight - radioFlick.height)
						const barY = Math.max(0, Math.min(track, local - radioThumb.height / 2))
						radioFlick.contentY = barY / track * span
					}

					onPressed: mouse => {
						const local = mapToItem(radioPane, mouse.x, mouse.y).y
						const onThumb = local >= radioThumb.y && local <= radioThumb.y + radioThumb.height
						if (!onThumb)
							scrollTo(local)
						origin = local
						originY = radioFlick.contentY
					}
					onPositionChanged: mouse => {
						if (!pressed)
							return
						const local = mapToItem(radioPane, mouse.x, mouse.y).y
						const track = Math.max(1, radioFlick.height - radioThumb.height)
						const span = Math.max(0, radioFlick.contentHeight - radioFlick.height)
						radioFlick.contentY = Math.max(0, Math.min(span, originY + (local - origin) * span / track))
					}
				}
			}
		}

		Item {
			id: secretRow
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
				text: Config.icon(Config.lock)
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
			id: appPane
			readonly property var appModel: {
				if (root.page === "audio")
					return AudioState.streamNodes
				if (root.page === "microphone")
					return AudioState.captureNodes
				return []
			}
			readonly property real rowBlock: root.rowHeight + Theme.menuSpacing + Theme.sliderSlot
			readonly property real full: appColumn.implicitHeight
			readonly property real budget: Math.max(0, root.room - Theme.padding - body.implicitHeight - column.spacing)
			visible: appModel.length > 0
			width: parent.width
			implicitHeight: Math.min(full, Math.max(budget, Math.min(full, rowBlock)))
			height: implicitHeight

			property string scrollPage: root.page
			onScrollPageChanged: appFlick.contentY = 0

			Flickable {
				id: appFlick
				anchors.fill: parent
				contentWidth: width
				contentHeight: appColumn.implicitHeight
				clip: true
				boundsBehavior: Flickable.StopAtBounds
				flickableDirection: Flickable.VerticalFlick
				interactive: contentHeight > height + 1

				Column {
					id: appColumn
					width: appFlick.width
					spacing: Theme.menuSpacing

					Repeater {
						model: appPane.appModel

						Column {
							id: appRow
							required property var modelData
							width: appColumn.width
							spacing: Theme.menuSpacing

							Item {
								width: parent.width
								height: root.rowHeight

								Rectangle {
									anchors.fill: parent
									anchors.leftMargin: Theme.inset
									anchors.rightMargin: Theme.inset
									radius: Theme.radius
									color: appMute.containsMouse ? root.ink(Theme.hover) : "transparent"
								}

								Text {
									id: appIcon
									anchors.left: parent.left
									anchors.leftMargin: Theme.headerInset
									anchors.verticalCenter: parent.verticalCenter
									text: {
										const audio = appRow.modelData.audio
										const level = audio ? audio.volume : 0
										const muted = audio ? audio.muted : false
										return root.page === "microphone" ? AudioState.micGlyph(level, muted) : AudioState.volumeGlyph(level, muted)
									}
									color: Theme.foreground
									font.family: Theme.iconFont
									font.pixelSize: Theme.iconSize
								}

								Text {
									anchors.left: appIcon.right
									anchors.leftMargin: Theme.gap
									anchors.right: appLevel.left
									anchors.rightMargin: Theme.gap
									anchors.verticalCenter: parent.verticalCenter
									text: AudioState.streamLabel(appRow.modelData)
									color: Theme.foreground
									font.family: Theme.fontFamily
									font.pixelSize: Theme.headingSize
									elide: Text.ElideRight
								}

								Text {
									id: appLevel
									anchors.right: parent.right
									anchors.rightMargin: Theme.headerInset
									anchors.verticalCenter: parent.verticalCenter
									text: AudioState.levelText(appRow.modelData.audio ? appRow.modelData.audio.volume : 0, appRow.modelData.audio ? appRow.modelData.audio.muted : false)
									color: appRow.modelData.audio && appRow.modelData.audio.muted ? root.ink(Theme.quiet) : Theme.foreground
									font.family: Theme.fontFamily
									font.pixelSize: Theme.fontSize
								}

								MouseArea {
									id: appMute
									anchors.fill: parent
									hoverEnabled: true
									cursorShape: Qt.PointingHandCursor
									onClicked: AudioState.toggleMute(appRow.modelData)
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
									value: appRow.modelData.audio ? appRow.modelData.audio.volume : 0
									onMoved: amount => AudioState.setVolume(appRow.modelData, amount)
								}
							}
						}
					}
				}
			}

			Item {
				id: appScroll
				visible: appFlick.contentHeight > appFlick.height + 1
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.right: parent.right
				width: Theme.inset + Theme.noticeProgress

				Rectangle {
					id: appThumb
					width: Theme.noticeProgress
					radius: width / 2
					anchors.horizontalCenter: parent.horizontalCenter
					color: appScrollDrag.containsMouse || appScrollDrag.pressed ? Theme.foreground : root.ink(Theme.scroll)
					height: Math.max(24, appFlick.height * appFlick.height / Math.max(appFlick.contentHeight, 1))
					y: appFlick.contentY / Math.max(1, appFlick.contentHeight - appFlick.height) * Math.max(0, appFlick.height - height)
				}

				MouseArea {
					id: appScrollDrag
					anchors.fill: parent
					hoverEnabled: true
					preventStealing: true
					cursorShape: Qt.PointingHandCursor
					property real origin: 0
					property real originY: 0

					function scrollTo(local) {
						const track = Math.max(1, appFlick.height - appThumb.height)
						const span = Math.max(0, appFlick.contentHeight - appFlick.height)
						const barY = Math.max(0, Math.min(track, local - appThumb.height / 2))
						appFlick.contentY = barY / track * span
					}

					onPressed: mouse => {
						const local = mapToItem(appPane, mouse.x, mouse.y).y
						const onThumb = local >= appThumb.y && local <= appThumb.y + appThumb.height
						if (!onThumb)
							scrollTo(local)
						origin = local
						originY = appFlick.contentY
					}
					onPositionChanged: mouse => {
						if (!pressed)
							return
						const local = mapToItem(appPane, mouse.x, mouse.y).y
						const track = Math.max(1, appFlick.height - appThumb.height)
						const span = Math.max(0, appFlick.contentHeight - appFlick.height)
						appFlick.contentY = Math.max(0, Math.min(span, originY + (local - origin) * span / track))
					}
				}
			}
		}
	}
}
