import QtQuick
import qs.settings
import qs.services

Column {
	id: root

	property real maxHeight: 480
	readonly property real listLimit: {
		let used = quietRow.height
		if (clearRow.visible)
			used += spacing + clearRow.height
		if (NoticeState.historyCount > 0)
			used += spacing
		return Math.max(Theme.rowHeight * 2, maxHeight - used)
	}

	spacing: 2

	function when(at) {
		return Qt.formatTime(new Date(at), Config.timeFormat)
	}

	function glyph(local, urgent) {
		if (Number(urgent) === 1)
			return Config.icon(Config.alert)
		if (Number(local) === 1)
			return Config.icon(Config.check)
		return Config.icon(Config.bell)
	}

	Item {
		id: quietRow
		width: parent.width
		height: Theme.rowHeight

		Rectangle {
			anchors.fill: parent
			anchors.leftMargin: Theme.inset
			anchors.rightMargin: Theme.inset
			radius: Theme.radius
			color: quietHover.containsMouse ? Theme.ink(Theme.buttonHover) : Theme.ink(Theme.wash)
		}

		Text {
			id: quietIcon
			anchors.left: parent.left
			anchors.leftMargin: Theme.headerInset
			anchors.verticalCenter: parent.verticalCenter
			text: Config.icon(NoticeState.quiet ? Config.bellOff : Config.bell)
			color: Theme.foreground
			font.family: Theme.iconFont
			font.pixelSize: Theme.iconSize
		}

		Text {
			anchors.left: quietIcon.right
			anchors.leftMargin: Theme.gap
			anchors.right: quietSwitch.left
			anchors.rightMargin: Theme.gap
			anchors.verticalCenter: parent.verticalCenter
			text: "Do not disturb"
			color: Theme.foreground
			font.family: Theme.fontFamily
			font.pixelSize: Theme.headingSize
			elide: Text.ElideRight
		}

		Item {
			id: quietSwitch
			anchors.right: parent.right
			anchors.rightMargin: Theme.edgeInset
			anchors.verticalCenter: parent.verticalCenter
			implicitWidth: Theme.toggleWidth
			implicitHeight: Theme.toggleHeight
			width: Theme.toggleWidth
			height: Theme.toggleHeight

			Rectangle {
				anchors.fill: parent
				radius: height / 2
				color: NoticeState.quiet ? Theme.foreground : Theme.ink(Theme.track)
			}

			Rectangle {
				width: Theme.toggleKnob
				height: Theme.toggleKnob
				radius: Theme.toggleKnob / 2
				anchors.verticalCenter: parent.verticalCenter
				x: NoticeState.quiet ? parent.width - width - Theme.toggleInset : Theme.toggleInset
				color: NoticeState.quiet ? Theme.background : Theme.foreground
			}
		}

		MouseArea {
			id: quietHover
			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor
			onClicked: NoticeState.quiet = !NoticeState.quiet
		}
	}

	Item {
		id: clearRow
		width: parent.width
		height: 28
		visible: NoticeState.historyCount > 0

		Item {
			anchors.right: parent.right
			anchors.rightMargin: Theme.inset
			anchors.verticalCenter: parent.verticalCenter
			implicitWidth: clearLabel.implicitWidth + 16
			implicitHeight: clearLabel.implicitHeight + 8
			width: implicitWidth
			height: implicitHeight

			Rectangle {
				anchors.fill: parent
				radius: Theme.buttonRadius
				color: clearHover.containsMouse ? Theme.ink(Theme.hover) : "transparent"
			}

			Text {
				id: clearLabel
				anchors.centerIn: parent
				text: "Clear"
				color: clearHover.containsMouse ? Theme.foreground : Theme.ink(Theme.muted)
				font.family: Theme.fontFamily
				font.pixelSize: Theme.smallSize
			}

			MouseArea {
				id: clearHover
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: NoticeState.clearHistory()
			}
		}
	}

	Text {
		id: emptyNote
		visible: NoticeState.historyCount === 0
		width: parent.width
		text: "No notifications"
		color: Theme.ink(Theme.muted)
		font.family: Theme.fontFamily
		font.pixelSize: Theme.fontSize
		horizontalAlignment: Text.AlignHCenter
		topPadding: 12
		bottomPadding: 16
	}

	Item {
		width: parent.width
		visible: NoticeState.historyCount > 0
		implicitHeight: Math.min(list.implicitHeight, root.listLimit)
		height: implicitHeight

		Flickable {
			id: flick
			anchors.fill: parent
			contentWidth: width
			contentHeight: list.implicitHeight
			clip: true
			boundsBehavior: Flickable.StopAtBounds
			flickableDirection: Flickable.VerticalFlick
			interactive: contentHeight > height + 1

			Column {
				id: list
				width: flick.width
				spacing: Theme.menuSpacing

				Repeater {
					model: NoticeState.history

					Item {
						id: row
						required property int index
						required property string app
						required property string summary
						required property string body
						required property string icon
						required property real at
						required property var urgent
						required property var local
						required property string kind
						readonly property bool shell: Number(local) === 1
						readonly property bool alarm: Number(urgent) === 1
						readonly property bool marked: shell || icon !== ""

						width: list.width
						implicitHeight: copy.implicitHeight + Theme.inset * 2
						height: implicitHeight

						Rectangle {
							anchors.fill: parent
							anchors.leftMargin: Theme.inset
							anchors.rightMargin: Theme.inset
							radius: Theme.rowRadius
							color: rowHover.hovered ? Theme.ink(Theme.hover) : "transparent"
						}

						HoverHandler {
							id: rowHover
						}

						Column {
							id: copy
							anchors.left: parent.left
							anchors.right: parent.right
							anchors.top: parent.top
							anchors.leftMargin: Theme.inset + 6
							anchors.rightMargin: Theme.inset + 6
							anchors.topMargin: Theme.inset
							spacing: Theme.menuSpacing

							Item {
								width: parent.width
								implicitHeight: Math.max(Theme.noticeIcon, nameRow.implicitHeight, stamp.implicitHeight)
								height: implicitHeight

								Row {
									id: nameRow
									width: Math.max(0, parent.width - stamp.implicitWidth - 8)
									spacing: 8
									anchors.verticalCenter: parent.verticalCenter

									Text {
										visible: row.shell
										text: root.glyph(row.local, row.urgent)
										color: row.alarm ? Theme.recording : Theme.foreground
										font.family: Theme.iconFont
										font.pixelSize: Theme.noticeIcon
									}

									Image {
										width: Theme.noticeIcon
										height: Theme.noticeIcon
										visible: !row.shell && row.icon !== "" && status === Image.Ready
										source: row.icon
										sourceSize.width: Theme.noticeIcon * 2
										sourceSize.height: Theme.noticeIcon * 2
										fillMode: Image.PreserveAspectFit
										asynchronous: true
									}

									Text {
										width: Math.max(0, nameRow.width - (row.marked ? Theme.noticeIcon + nameRow.spacing : 0))
										text: row.app
										color: Theme.ink(Theme.iconMute)
										font.family: Theme.fontFamily
										font.pixelSize: Theme.labelSize
										elide: Text.ElideRight
									}
								}

								Text {
									id: stamp
									anchors.right: parent.right
									anchors.verticalCenter: parent.verticalCenter
									text: root.when(row.at)
									color: Theme.ink(Theme.iconMute)
									font.family: Theme.fontFamily
									font.pixelSize: Theme.labelSize
								}
							}

							Text {
								width: parent.width
								visible: text !== ""
								text: row.summary
								color: Theme.foreground
								font.family: Theme.fontFamily
								font.pixelSize: Theme.fontSize
								wrapMode: Text.WordWrap
								maximumLineCount: Theme.noticeSummaryLines
								elide: Text.ElideRight
							}

							Text {
								id: bodyText
								width: parent.width
								visible: text !== ""
								text: row.shell ? row.body : NoticeState.markup(row.body)
								color: Theme.ink(Theme.body)
								linkColor: Theme.link
								font.family: row.kind === "reload" && row.alarm ? Theme.monoFamily : Theme.fontFamily
								font.pixelSize: Theme.fontSize
								wrapMode: Text.WordWrap
								maximumLineCount: row.kind === "reload" ? Theme.noticeErrorLines : Theme.noticeBodyLines
								elide: Text.ElideRight
								textFormat: row.shell ? Text.PlainText : Text.RichText
								onLinkActivated: link => NoticeState.openLink(link)

								HoverHandler {
									cursorShape: bodyText.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
								}
							}
						}
					}
				}
			}
		}

		Rectangle {
			visible: flick.contentHeight > flick.height + 1
			width: Theme.noticeProgress
			radius: Theme.noticeProgress / 2
			color: Theme.ink(Theme.scroll)
			height: Math.max(24, flick.height * flick.height / Math.max(flick.contentHeight, 1))
			x: parent.width - width - Theme.inset
			y: flick.contentY / Math.max(1, flick.contentHeight - flick.height) * Math.max(0, flick.height - height)
		}
	}
}
