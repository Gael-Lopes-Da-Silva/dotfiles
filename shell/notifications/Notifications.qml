pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs
import qs.common

Item {
	id: notifications

	property var toasts: []

	function toastTime(notification) {
		if (!notification || notification.urgency === NotificationUrgency.Critical)
			return 0
		if (notification.expireTimeout > 0)
			return Math.round(notification.expireTimeout * 1000)
		if (notification.expireTimeout === 0)
			return 0
		return notification.urgency === NotificationUrgency.Low ? 4000 : 5000
	}

	function push(notification) {
		if (!notification.transient)
			notification.tracked = true
		const next = toasts.filter(item => item.id !== notification.id)
		next.unshift(notification)
		toasts = next.slice(0, 3)
		toastSurface.summon()
	}

	function drop(notification) {
		toasts = toasts.filter(item => item !== notification)
		if (toasts.length === 0)
			toastSurface.dismiss()
	}

	function toggle() {
		if (history.shown)
			history.dismiss()
		else
			history.summon()
	}

	readonly property var recent: {
		const items = server.trackedNotifications.values
		const list = []
		for (let i = 0; i < items.length; i++) {
			if (!items[i].transient)
				list.push(items[i])
		}
		return list
	}

	NotificationServer {
		id: server
		keepOnReload: true
		bodySupported: true
		actionsSupported: true
		onNotification: notification => notifications.push(notification)
	}

	Surface {
		id: toastSurface
		lifetime: "transient"
		timed: false
		edge: "top"
		namespace: "toasts"

		content: Item {
			implicitWidth: 360
			implicitHeight: stack.implicitHeight

			Column {
			id: stack
			width: 360
			spacing: 8

			Repeater {
				model: notifications.toasts

				Rectangle {
					id: toast
					required property var modelData
					width: 360
					implicitHeight: body.implicitHeight + Theme.padding * 2
					radius: Theme.radius
					color: Theme.background
					border.color: Theme.border
					border.width: 1

					property double remaining: notifications.toastTime(modelData)
					property double startedAt: 0

					function start() {
						if (remaining <= 0)
							return
						startedAt = Date.now()
						timer.interval = Math.max(1, remaining)
						timer.restart()
					}

					Timer {
						id: timer
						onTriggered: notifications.drop(toast.modelData)
					}

					HoverHandler {
						onHoveredChanged: {
							if (hovered) {
								if (timer.running)
									toast.remaining = Math.max(0, toast.remaining - (Date.now() - toast.startedAt))
								timer.stop()
							} else {
								toast.start()
							}
						}
					}

					Component.onCompleted: start()

					Connections {
						target: toast.modelData
						function onClosed() {
							notifications.drop(toast.modelData)
						}
					}

					MouseArea {
						anchors.fill: parent
						onClicked: toast.modelData.dismiss()
					}

					Column {
						id: body
						x: Theme.padding
						y: Theme.padding
						width: parent.width - Theme.padding * 2
						spacing: 6

						Text {
							width: parent.width
							text: toast.modelData.appName || "Notification"
							color: Theme.muted
							font.family: Theme.fontFamily
							font.pixelSize: 12
							elide: Text.ElideRight
						}

						Text {
							width: parent.width
							visible: toast.modelData.summary.length > 0
							text: toast.modelData.summary
							color: Theme.foreground
							font.family: Theme.fontFamily
							font.pixelSize: Theme.fontSize
							wrapMode: Text.WordWrap
							maximumLineCount: 2
							elide: Text.ElideRight
						}

						Text {
							width: parent.width
							visible: toast.modelData.body.length > 0
							text: toast.modelData.body
							color: Theme.muted
							font.family: Theme.fontFamily
							font.pixelSize: Theme.fontSize
							wrapMode: Text.WordWrap
							maximumLineCount: 3
							elide: Text.ElideRight
							textFormat: Text.PlainText
						}

						Flow {
							width: parent.width
							spacing: 4
							visible: toast.modelData.actions.length > 0 || toast.remaining <= 0

							Repeater {
								model: toast.modelData.actions

								Button {
									required property var modelData
									text: modelData.text
									onClicked: modelData.invoke()
								}
							}

							Button {
								visible: toast.remaining <= 0
								text: "Dismiss"
								onClicked: toast.modelData.dismiss()
							}
						}
					}
				}
			}
		}
		}
	}

	Surface {
		id: history
		lifetime: "session"
		edge: "center"
		wantsKeyboard: true
		namespace: "notifications"

		content: Rectangle {
			implicitWidth: 420
			implicitHeight: column.implicitHeight + Theme.padding * 2
			radius: Theme.radius
			color: Theme.background
			border.color: Theme.border
			border.width: 1

			Column {
				id: column
				x: Theme.padding
				y: Theme.padding
				width: 420 - Theme.padding * 2
				spacing: Theme.gap

				Text {
					text: "Notifications"
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
				}

				Text {
					visible: notifications.recent.length === 0
					text: "Nothing recent"
					color: Theme.muted
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
				}

				Flickable {
					width: parent.width
					height: Math.min(list.implicitHeight, 480)
					contentHeight: list.implicitHeight
					clip: true
					visible: notifications.recent.length > 0

					Column {
						id: list
						width: parent.width
						spacing: 8

						Repeater {
							model: notifications.recent

							Rectangle {
								id: row
								required property var modelData
								width: parent.width
								implicitHeight: details.implicitHeight + 12
								radius: 8
								color: "transparent"

								Column {
									id: details
									x: 6
									y: 6
									width: parent.width - 12
									spacing: 4

									Text {
										width: parent.width
										text: row.modelData.summary || row.modelData.appName
										color: Theme.foreground
										font.family: Theme.fontFamily
										font.pixelSize: Theme.fontSize
										elide: Text.ElideRight
									}

									Text {
										width: parent.width
										visible: row.modelData.body.length > 0
										text: row.modelData.body
										color: Theme.muted
										font.family: Theme.fontFamily
										font.pixelSize: 13
										wrapMode: Text.WordWrap
										maximumLineCount: 2
										elide: Text.ElideRight
										textFormat: Text.PlainText
									}

									Flow {
										width: parent.width
										spacing: 4

										Repeater {
											model: row.modelData.actions

											Button {
												required property var modelData
												text: modelData.text
												onClicked: modelData.invoke()
											}
										}

										Button {
											text: "Dismiss"
											onClicked: row.modelData.dismiss()
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
