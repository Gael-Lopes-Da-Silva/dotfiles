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
				model: NoticeState.model

				Item {
					id: card
					required property int nid
					required property real duration
					required property real remaining
					readonly property var notification: NoticeState.lookup(nid)
					readonly property bool critical: notification && notification.urgency === NotificationUrgency.Critical

					width: Theme.notificationWidth
					implicitHeight: stack.implicitHeight
					height: implicitHeight

					Column {
						id: stack
						width: parent.width
						spacing: 6

						Rectangle {
							width: parent.width
							implicitHeight: copy.implicitHeight + Theme.padding * 2
							radius: Theme.radius
							color: Theme.background

							Column {
								id: copy
								anchors.left: parent.left
								anchors.right: parent.right
								anchors.top: parent.top
								anchors.margins: Theme.padding
								spacing: 2

								Text {
									width: parent.width
									visible: card.notification && (card.notification.appName || "") !== ""
									text: card.notification ? card.notification.appName : ""
									color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.55)
									font.family: Theme.fontFamily
									font.pixelSize: Theme.fontSize - 2
									elide: Text.ElideRight
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
									width: parent.width
									visible: text !== ""
									text: card.notification ? NoticeState.plain(card.notification.body) : ""
									color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.82)
									font.family: Theme.fontFamily
									font.pixelSize: Theme.fontSize
									wrapMode: Text.WordWrap
									maximumLineCount: 4
									elide: Text.ElideRight
									textFormat: Text.PlainText
								}
							}

							MouseArea {
								anchors.fill: parent
								cursorShape: Qt.PointingHandCursor
								onClicked: {
									if (card.notification)
										card.notification.dismiss()
								}
								onWheel: wheel => wheel.accepted = false
							}
						}

						Rectangle {
							width: parent.width
							height: 3
							radius: 1.5
							color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.16)

							Rectangle {
								width: parent.width * (card.duration > 0 ? card.remaining / card.duration : 0)
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
