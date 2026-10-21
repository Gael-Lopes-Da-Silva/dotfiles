// Toast stack on the focused screen. Options live in config.json "notices".
import QtQuick
import Quickshell.Services.Notifications
import qs.services
import qs.settings

Item {
	id: root

	property real maxHeight: 420

	implicitWidth: Config.notices.popupWidth
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
			width: Config.notices.popupWidth
			spacing: 0

			Repeater {
				model: NoticeState.entries

				Item {
					id: card
					required property var nid
					required property real duration
					required property real remaining
					required property var local
					required property string summary
					required property string body
					required property var urgent
					required property var closing
					required property string kind
					readonly property bool synthetic: local === 1
					readonly property var notification: {
						const _ = NoticeState.trackedCount
						if (synthetic)
							return null
						return NoticeState.lookup(nid)
					}
					readonly property bool critical: synthetic ? urgent === 1 : notification && notification.urgency === NotificationUrgency.Critical
					readonly property string pictureRaw: notification && notification.image ? String(notification.image) : ""
					readonly property bool pictureIsIcon: pictureRaw.indexOf("image://icon/") === 0
					readonly property string pictureSource: pictureRaw !== "" && !pictureIsIcon ? pictureRaw : ""
					readonly property string appIconSource: {
						if (synthetic)
							return ""
						const fromApp = NoticeState.iconSource(notification ? notification.appIcon : "")
						if (fromApp)
							return fromApp
						return pictureIsIcon ? pictureRaw : ""
					}
					readonly property var buttons: {
						if (synthetic) {
							if (kind !== "reload")
								return []
							const list = []
							if (critical && body)
								list.push({ text: "Copy error", copy: body })
							list.push({ text: "Copy log command", copy: NoticeState.logCommand() })
							return list
						}
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
						if (synthetic) {
							NoticeState.removeId(nid)
							return
						}
						const note = notification
						if (!note)
							return
						NoticeState.activate(note)
					}

					function close() {
						if (synthetic || !notification) {
							NoticeState.removeId(nid)
							return
						}
						notification.dismiss()
					}

					function sendReply() {
						const note = notification
						if (!note || !replyInput.text)
							return
						note.sendInlineReply(replyInput.text)
						replyInput.text = ""
						NoticeState.replying = false
					}

					readonly property bool shown: !NoticeState.quiet || critical
					readonly property bool leaving: closing === 1
					property bool arrived: false
					property bool faceReady: false
					property string faceSummary: ""
					property string faceBody: ""
					property string faceApp: ""
					readonly property real fullHeight: copy.implicitHeight + Theme.padding * 2 + Theme.gap

					function captureFace() {
						if (faceReady)
							return
						if (synthetic) {
							faceSummary = summary
							faceBody = body
							faceApp = Config.notices.name
						} else if (notification) {
							faceSummary = NoticeState.plain(notification.summary)
							faceBody = NoticeState.markup(notification.body)
							faceApp = notification.appName || ""
						} else {
							for (let i = 0; i < NoticeState.history.count; i++) {
								const row = NoticeState.history.get(i)
								if (row.nid !== nid)
									continue
								faceSummary = row.summary || ""
								faceBody = NoticeState.markup(row.body || "")
								faceApp = row.app || ""
								break
							}
						}
						faceReady = true
					}

					width: Config.notices.popupWidth
					clip: true
					height: arrived && shown && !leaving ? fullHeight : 0
					opacity: arrived && shown && !leaving ? 1 : 0

					Behavior on height {
						NumberAnimation {
							duration: Theme.motion
							easing.type: Easing.BezierSpline
							easing.bezierCurve: Theme.curve
						}
					}

					Behavior on opacity {
						NumberAnimation { duration: Theme.motion }
					}

					Timer {
						id: leaveTimer
						interval: Theme.motion
						onTriggered: NoticeState.finishRemove(card.nid)
					}

					Component.onCompleted: Qt.callLater(() => { arrived = true })
					onLeavingChanged: {
						if (!leaving)
							return
						captureFace()
						leaveTimer.start()
					}

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

						Item {
							width: parent.width
							implicitHeight: Math.max(Config.notices.iconSize, dismiss.height)
							height: implicitHeight

							Row {
								id: nameRow
								width: Math.max(0, parent.width - dismiss.width - 8)
								spacing: 8
								anchors.verticalCenter: parent.verticalCenter
								visible: card.appIconSource !== "" || card.synthetic || (card.notification && (card.notification.appName || "") !== "")

								Text {
									visible: card.synthetic
									text: card.kind === "power" ? PowerState.batteryGlyph() : Config.icon(card.critical ? Config.notices.alertIcon : Config.notices.checkIcon)
									color: card.critical ? Theme.recording : Theme.foreground
									font.family: Theme.iconFont
									font.pixelSize: Config.notices.iconSize
								}

								Image {
									width: Config.notices.iconSize
									height: Config.notices.iconSize
									visible: !card.synthetic && status === Image.Ready
									source: card.appIconSource
									sourceSize.width: Config.notices.iconSize * 2
									sourceSize.height: Config.notices.iconSize * 2
									fillMode: Image.PreserveAspectFit
									asynchronous: true
								}

								Text {
									width: Math.max(0, nameRow.width - (card.synthetic || card.appIconSource !== "" ? Config.notices.iconSize + nameRow.spacing : 0))
									text: card.faceReady ? card.faceApp : (card.synthetic ? Config.notices.name : (card.notification ? card.notification.appName : ""))
									color: Theme.ink(Theme.iconMuted)
									font.family: Theme.fontFamily
									font.pixelSize: Theme.labelSize
									elide: Text.ElideRight
								}
							}

							Item {
								id: dismiss
								anchors.right: parent.right
								anchors.verticalCenter: parent.verticalCenter
								width: Config.notices.iconSize
								height: Config.notices.iconSize

								Rectangle {
									anchors.fill: parent
									radius: width / 2
									color: dismissHover.containsMouse ? Theme.ink(Theme.buttonHover) : "transparent"
								}

								Text {
									anchors.centerIn: parent
									text: Config.icon(Config.notices.closeIcon)
									color: dismissHover.containsMouse ? Theme.foreground : Theme.ink(Theme.iconMuted)
									font.family: Theme.iconFont
									font.pixelSize: Theme.labelSize
								}

								MouseArea {
									id: dismissHover
									anchors.fill: parent
									hoverEnabled: true
									cursorShape: Qt.PointingHandCursor
									onClicked: card.close()
									onWheel: wheel => wheel.accepted = false
								}
							}
						}

						Image {
							id: picture
							width: parent.width
							visible: card.pictureSource !== "" && status === Image.Ready
							source: card.pictureSource
							fillMode: Image.PreserveAspectFit
							asynchronous: true
							sourceSize.width: Config.notices.popupWidth
							sourceSize.height: Config.notices.imageSource
							height: {
								if (!visible || implicitWidth < 1)
									return 0
								return Math.min(Config.notices.imageHeight, implicitHeight * width / implicitWidth)
							}
						}

						Text {
							width: parent.width
							text: card.faceReady ? card.faceSummary : (card.synthetic ? card.summary : (card.notification ? NoticeState.plain(card.notification.summary) : ""))
							color: Theme.foreground
							font.family: Theme.fontFamily
							font.pixelSize: Theme.fontSize
							wrapMode: Text.WordWrap
							maximumLineCount: Config.notices.summaryLines
							elide: Text.ElideRight
						}

						Text {
							id: bodyText
							width: parent.width
							visible: text !== ""
							clip: true
							text: card.faceReady ? card.faceBody : (card.synthetic ? card.body : (card.notification ? NoticeState.markup(card.notification.body) : ""))
							color: Theme.ink(Theme.body)
							linkColor: Theme.link
							font.family: card.kind === "reload" && card.critical ? Theme.monoFamily : Theme.fontFamily
							font.pixelSize: Theme.fontSize
							wrapMode: Text.WordWrap
							maximumLineCount: card.kind === "reload" ? Config.notices.errorLines : Config.notices.bodyLines
							elide: Text.ElideRight
							textFormat: card.synthetic ? Text.PlainText : Text.RichText
							onLinkActivated: link => NoticeState.openLink(link)

							HoverHandler {
								cursorShape: bodyText.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
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
									implicitHeight: Config.notices.actionHeight
									width: implicitWidth
									height: implicitHeight
									radius: Theme.buttonRadius
									color: Theme.ink(actionHover.hovered ? Theme.buttonHover : Theme.field)

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
											font.pixelSize: Theme.smallSize
										}
									}

									HoverHandler {
										id: actionHover
									}

									MouseArea {
										anchors.fill: parent
										cursorShape: Qt.PointingHandCursor
										onClicked: {
											const action = actionButton.modelData
											if (action.copy !== undefined)
												NoticeState.copyText(action.copy)
											else
												action.invoke()
										}
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
								height: Config.notices.replyHeight
								radius: Theme.buttonRadius
								color: Theme.ink(Theme.field)

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
										color: Theme.ink(Theme.dim)
										font.family: Theme.fontFamily
										font.pixelSize: Theme.fontSize
										elide: Text.ElideRight
									}
								}
							}

							Rectangle {
								id: replySend
								width: Config.notices.replyHeight
								height: Config.notices.replyHeight
								radius: Theme.buttonRadius
								color: Theme.ink(replySendHover.hovered ? Theme.buttonHover : Theme.field)

								Text {
									anchors.centerIn: parent
									text: Config.icon(Config.notices.replyIcon)
									color: Theme.foreground
									font.family: Theme.iconFont
									font.pixelSize: Config.notices.replyIconSize
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
							height: Theme.scrollSize
							radius: Theme.scrollSize / 2
							visible: card.duration > 0 || card.critical
							color: Theme.ink(Theme.track)

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
		width: Theme.scrollSize
		radius: Theme.scrollSize / 2
		color: Theme.ink(Theme.scroll)
		height: Math.max(24, flick.height * flick.height / Math.max(flick.contentHeight, 1))
		x: parent.width - width
		y: flick.contentY / Math.max(1, flick.contentHeight - flick.height) * Math.max(0, flick.height - height)
	}

	HoverHandler {
		onHoveredChanged: NoticeState.paused = hovered
	}
}
