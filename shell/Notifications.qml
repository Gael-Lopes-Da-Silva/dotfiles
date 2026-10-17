import QtQuick
import Quickshell.Services.Notifications

Item {
	id: root

	property real maxHeight: 420

	implicitWidth: Theme.notificationWidth
	implicitHeight: Math.min(Math.max(column.implicitHeight, 0), maxHeight)
	width: implicitWidth
	height: implicitHeight

	Flickable {
		id: flick
		anchors.fill: parent
		contentWidth: width
		contentHeight: column.implicitHeight
		clip: true
		boundsBehavior: Flickable.StopAtBounds
		flickableDirection: Flickable.VerticalFlick
		interactive: contentHeight > height + 1

		Column {
			id: column
			width: Theme.notificationWidth
			spacing: Theme.gap

			Repeater {
				model: NoticeState.entries

				Item {
					id: card
					required property var nid
					required property real duration
					required property real remaining
					readonly property var notification: {
						const _ = NoticeState.trackedCount
						return NoticeState.lookup(nid)
					}
					readonly property bool critical: notification && notification.urgency === NotificationUrgency.Critical
					readonly property string pictureRaw: notification && notification.image ? String(notification.image) : ""
					readonly property bool pictureIsIcon: pictureRaw.indexOf("image://icon/") === 0
					readonly property string pictureSource: pictureRaw !== "" && !pictureIsIcon ? pictureRaw : ""
					readonly property string appIconSource: {
						const fromApp = NoticeState.iconSource(notification ? notification.appIcon : "")
						if (fromApp)
							return fromApp
						return pictureIsIcon ? pictureRaw : ""
					}
					readonly property var buttons: {
						const note = notification
						if (!note || !note.actions)
							return []
						const list = []
						for (let i = 0; i < note.actions.length; i++) {
							if (note.actions[i].identifier !== "default")
								list.push(note.actions[i])
						}
						return list
					}

					function activate() {
						const note = notification
						if (!note)
							return
						const actions = note.actions || []
						for (let i = 0; i < actions.length; i++) {
							if (actions[i].identifier === "default") {
								actions[i].invoke()
								return
							}
						}
						note.dismiss()
					}

					function sendReply() {
						const note = notification
						if (!note || !replyInput.text)
							return
						note.sendInlineReply(replyInput.text)
						replyInput.text = ""
						NoticeState.replying = false
					}

					width: Theme.notificationWidth
					implicitHeight: copy.implicitHeight + Theme.padding * 2
					height: implicitHeight

					MouseArea {
						anchors.fill: parent
						cursorShape: Qt.PointingHandCursor
						onClicked: card.activate()
						onWheel: wheel => wheel.accepted = false
					}

					Column {
						id: copy
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.top: parent.top
						anchors.margins: Theme.padding
						spacing: 8

						Row {
							width: parent.width
							spacing: 8
							visible: card.appIconSource !== "" || (card.notification && (card.notification.appName || "") !== "")

							Image {
								width: 18
								height: 18
								visible: status === Image.Ready
								source: card.appIconSource
								sourceSize.width: 36
								sourceSize.height: 36
								fillMode: Image.PreserveAspectFit
								asynchronous: true
							}

							Text {
								width: Math.max(0, parent.width - (card.appIconSource !== "" ? 26 : 0))
								text: card.notification ? card.notification.appName : ""
								color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.55)
								font.family: Theme.fontFamily
								font.pixelSize: Theme.fontSize - 2
								elide: Text.ElideRight
							}
						}

						Image {
							id: picture
							width: parent.width
							visible: card.pictureSource !== "" && status === Image.Ready
							source: card.pictureSource
							fillMode: Image.PreserveAspectFit
							asynchronous: true
							sourceSize.width: Theme.notificationWidth
							sourceSize.height: 360
							height: {
								if (!visible || implicitWidth < 1)
									return 0
								return Math.min(160, implicitHeight * width / implicitWidth)
							}
						}

						Text {
							width: parent.width
							text: card.notification ? NoticeState.plain(card.notification.summary) : ""
							color: Theme.foreground
							font.family: Theme.fontFamily
							font.pixelSize: Theme.fontSize
							wrapMode: Text.WordWrap
							maximumLineCount: 2
							elide: Text.ElideRight
						}

						Text {
							id: body
							width: parent.width
							visible: text !== ""
							text: card.notification ? NoticeState.markup(card.notification.body) : ""
							color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.82)
							linkColor: "#9ecbff"
							font.family: Theme.fontFamily
							font.pixelSize: Theme.fontSize
							wrapMode: Text.WordWrap
							maximumLineCount: 8
							elide: Text.ElideRight
							textFormat: Text.RichText
							onLinkActivated: link => NoticeState.openLink(link)

							HoverHandler {
								cursorShape: body.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
							}
						}

						Flow {
							width: parent.width
							spacing: 6
							visible: card.buttons.length > 0

							Repeater {
								model: card.buttons

								Rectangle {
									id: actionButton
									required property var modelData
									readonly property string icon: card.notification && card.notification.hasActionIcons ? NoticeState.iconSource(modelData.identifier) : ""

									implicitWidth: Math.min(copy.width, actionRow.implicitWidth + 16)
									implicitHeight: 28
									width: implicitWidth
									height: implicitHeight
									radius: 8
									color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, actionHover.hovered ? 0.18 : 0.1)

									Row {
										id: actionRow
										anchors.centerIn: parent
										spacing: 6

										Image {
											width: 14
											height: 14
											visible: actionButton.icon !== "" && status === Image.Ready
											source: actionButton.icon
											sourceSize.width: 28
											sourceSize.height: 28
											fillMode: Image.PreserveAspectFit
											asynchronous: true
										}

										Text {
											text: actionButton.modelData.text || ""
											color: Theme.foreground
											font.family: Theme.fontFamily
											font.pixelSize: Theme.fontSize - 1
										}
									}

									HoverHandler {
										id: actionHover
									}

									MouseArea {
										anchors.fill: parent
										cursorShape: Qt.PointingHandCursor
										onClicked: actionButton.modelData.invoke()
										onWheel: wheel => wheel.accepted = false
									}
								}
							}
						}

						Row {
							id: replyRow
							width: parent.width
							spacing: 8
							visible: card.notification && card.notification.hasInlineReply

							Rectangle {
								width: parent.width - replySend.width - replyRow.spacing
								height: 32
								radius: 8
								color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.1)

								TextInput {
									id: replyInput
									anchors.fill: parent
									anchors.leftMargin: 10
									anchors.rightMargin: 10
									verticalAlignment: TextInput.AlignVCenter
									color: Theme.foreground
									font.family: Theme.fontFamily
									font.pixelSize: Theme.fontSize
									clip: true
									selectByMouse: true
									onActiveFocusChanged: NoticeState.replying = activeFocus
									onAccepted: card.sendReply()

									Text {
										anchors.fill: parent
										verticalAlignment: Text.AlignVCenter
										visible: !replyInput.text && !replyInput.activeFocus
										text: card.notification ? (card.notification.inlineReplyPlaceholder || "") : ""
										color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.4)
										font.family: Theme.fontFamily
										font.pixelSize: Theme.fontSize
										elide: Text.ElideRight
									}
								}
							}

							Rectangle {
								id: replySend
								width: 32
								height: 32
								radius: 8
								color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, replySendHover.hovered ? 0.18 : 0.1)

								Text {
									anchors.centerIn: parent
									text: String.fromCodePoint(0xF048A)
									color: Theme.foreground
									font.family: Theme.iconFont
									font.pixelSize: 16
								}

								HoverHandler {
									id: replySendHover
								}

								MouseArea {
									anchors.fill: parent
									cursorShape: Qt.PointingHandCursor
									onClicked: card.sendReply()
									onWheel: wheel => wheel.accepted = false
								}
							}
						}

						Rectangle {
							width: parent.width
							height: 3
							radius: 1.5
							visible: card.duration > 0 || card.critical
							color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.16)

							Rectangle {
								width: parent.width * (card.duration > 0 ? card.remaining / card.duration : 1)
								height: parent.height
								radius: parent.radius
								color: card.critical ? Theme.recording : Theme.foreground
							}
						}
					}
				}
			}
		}
	}

	Rectangle {
		visible: flick.contentHeight > flick.height + 1
		width: 3
		radius: 1.5
		color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.35)
		height: Math.max(24, flick.height * flick.height / Math.max(flick.contentHeight, 1))
		x: parent.width - width
		y: flick.visibleArea.yPosition * (flick.height - height)
	}

	HoverHandler {
		onHoveredChanged: NoticeState.paused = hovered
	}
}
