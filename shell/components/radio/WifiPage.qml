// Wi-Fi page of the radio menu: radio toggle, ethernet, networks, and the password field.
import QtQuick
import Quickshell.Networking
import qs.components.controls
import qs.services
import qs.lib

Item {
	id: root
	property string page: ""
	property bool live: true
	property real room: 4096
	readonly property int menuWidth: Config.radio.menuWidth
	readonly property int rowHeight: Theme.rowHeight

	implicitWidth: menuWidth
	implicitHeight: column.implicitHeight
	width: implicitWidth
	height: implicitHeight

	function ink(alpha) {
		return Theme.ink(alpha)
	}

	Column {
		id: column
		width: parent.width
		spacing: Theme.menuSpacing

		Column {
			id: head
			width: parent.width
			spacing: Theme.menuSpacing

			Item {
				width: parent.width
				height: root.rowHeight

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
					anchors.leftMargin: Theme.menuInset
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
					anchors.rightMargin: Theme.menuEdge
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
				visible: RadioState.wired !== null
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
						width: Theme.iconWell
						height: Theme.iconWell
						radius: Theme.buttonRadius
						color: root.ink(Theme.wellFill)

						Text {
							anchors.centerIn: parent
							text: Config.icon(Config.radio.ethernetIcon)
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
				visible: radioPane.radioModel.length === 0
				width: parent.width
				text: !Networking.wifiEnabled ? "Wi-Fi is off" : RadioState.wifiReady ? "No networks" : "Scanning"
				color: root.ink(Theme.muted)
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
				horizontalAlignment: Text.AlignHCenter
				topPadding: 10
				bottomPadding: 8
			}
		}

		Item {
			id: radioPane
			// The close animation is still showing this list, so keep the last one until it is gone.
			property bool live: root.live
			property var radioModel: []
			readonly property var radioSource: RadioState.wifiList

			onLiveChanged: {
				if (live)
					radioModel = radioSource
			}
			onRadioSourceChanged: {
				if (live)
					radioModel = radioSource
			}
			readonly property real rowBlock: Theme.rowInnerHeight
			readonly property real full: radioColumn.implicitHeight
			readonly property real tail: secretRow.visible ? secretRow.height + column.spacing : 0
			readonly property real budget: Math.max(0, root.room - Theme.padding - head.implicitHeight - column.spacing - tail)
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
						model: radioPane.radioModel

						Rectangle {
							id: wifiRow
							required property var modelData
							readonly property real liveSignal: modelData.signalStrength || 0
							readonly property bool liveConnected: !!modelData.connected
							readonly property bool liveSecured: RadioState.secured(modelData)
							readonly property string liveName: modelData.name || ""
							property real heldSignal: 0
							property bool heldConnected: false
							property bool heldSecured: false
							property string heldName: ""
							readonly property real signal: radioPane.live ? liveSignal : heldSignal
							readonly property bool connected: radioPane.live ? liveConnected : heldConnected
							readonly property bool secured: radioPane.live ? liveSecured : heldSecured
							readonly property string title: radioPane.live ? liveName : heldName

							function remember() {
								if (!radioPane.live)
									return
								heldSignal = liveSignal
								heldConnected = liveConnected
								heldSecured = liveSecured
								heldName = liveName
							}

							Component.onCompleted: remember()
							onLiveSignalChanged: remember()
							onLiveConnectedChanged: remember()
							onLiveSecuredChanged: remember()
							onLiveNameChanged: remember()

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
								width: Theme.iconWell
								height: Theme.iconWell
								radius: Theme.buttonRadius
								color: root.ink(Theme.wellFill)

								Text {
									anchors.centerIn: parent
									text: RadioState.strengthGlyph(wifiRow.signal)
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
								visible: wifiRow.secured
								text: Config.icon(Config.radio.lockIcon)
								color: root.ink(Theme.iconMuted)
								font.family: Theme.iconFont
								font.pixelSize: Theme.fontSize
							}

							Text {
								id: status
								anchors.right: parent.right
								anchors.rightMargin: 12
								anchors.verticalCenter: parent.verticalCenter
								text: wifiRow.connected ? "Connected" : Math.round(wifiRow.signal * 100) + "%"
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
								text: wifiRow.title
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

									}
			}

			Item {
				id: radioScroll
				visible: radioFlick.contentHeight > radioFlick.height + 1
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.right: parent.right
				width: Theme.inset + Theme.scrollSize

				Rectangle {
					id: radioThumb
					width: Theme.scrollSize
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
			visible: RadioState.pending !== null
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
				anchors.leftMargin: Theme.menuInset
				anchors.verticalCenter: parent.verticalCenter
				text: Config.icon(Config.radio.lockIcon)
				color: root.ink(Theme.iconMuted)
				font.family: Theme.iconFont
				font.pixelSize: Theme.glyphSize
			}

			TextInput {
				id: secret
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: 46
				anchors.rightMargin: Theme.menuEdge
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
	}
}
