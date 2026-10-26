// Bluetooth page of the radio menu: adapter toggle and paired devices.
import QtQuick
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
					color: btHeadHover.containsMouse ? root.ink(Theme.buttonHover) : root.ink(Theme.wash)
				}

				Text {
					id: btHeadIcon
					anchors.left: parent.left
					anchors.leftMargin: Theme.menuInset
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
					anchors.rightMargin: Theme.menuEdge
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
				visible: radioPane.radioModel.length === 0
				width: parent.width
				text: {
					const adapter = RadioState.bluetooth
					if (adapter && !adapter.enabled)
						return "Bluetooth is off"
					if (!adapter)
						return RadioState.btWarm ? "Bluetooth is off" : "Scanning"
					return RadioState.btReady ? "No devices" : "Scanning"
				}
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
			readonly property var radioSource: RadioState.btList

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
			readonly property real tail: 0
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
								width: Theme.iconWell
								height: Theme.iconWell
								radius: Theme.buttonRadius
								color: root.ink(Theme.wellFill)

								Text {
									anchors.centerIn: parent
									text: Config.icon(btRow.connected ? Config.radio.bluetoothOnIcon : Config.radio.bluetoothIdleIcon)
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
									if (btRow.modelData.connected && btRow.modelData.batteryAvailable)
										return Math.round(btRow.modelData.battery * 100) + "%"
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
	}
}
