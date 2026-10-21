// Speaker or microphone page: the default device and the per-app streams.
import QtQuick
import qs.components.controls
import qs.services
import qs.lib

Item {
	id: root

	property string page: ""
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
					anchors.leftMargin: Theme.menuInset
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
					anchors.rightMargin: Theme.menuInset
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
				height: Config.audio.sliderSlot

				VolumeBar {
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					anchors.leftMargin: Theme.menuInset
					anchors.rightMargin: Theme.menuInset
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
				leftPadding: Theme.menuInset
				topPadding: 8
				bottomPadding: 2
			}

			Text {
				visible: root.page === "audio" && AudioState.sinkNodes.length === 0
				width: parent.width
				text: AudioState.settled ? "No outputs" : "Loading"
				color: root.ink(Theme.muted)
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
				horizontalAlignment: Text.AlignHCenter
				topPadding: 8
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
					anchors.leftMargin: Theme.menuInset
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
					anchors.rightMargin: Theme.menuInset
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
				height: Config.audio.sliderSlot

				VolumeBar {
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					anchors.leftMargin: Theme.menuInset
					anchors.rightMargin: Theme.menuInset
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
				leftPadding: Theme.menuInset
				topPadding: 8
				bottomPadding: 2
			}

			Text {
				visible: root.page === "microphone" && AudioState.sourceNodes.length === 0
				width: parent.width
				text: AudioState.settled ? "No microphones" : "Loading"
				color: root.ink(Theme.muted)
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
				horizontalAlignment: Text.AlignHCenter
				topPadding: 8
				bottomPadding: 6
			}
		}

		Item {
			id: nodePane
			readonly property var nodeModel: {
				if (root.page === "audio")
					return AudioState.sinkNodes
				if (root.page === "microphone")
					return AudioState.sourceNodes
				return []
			}
			readonly property real rowBlock: Theme.rowInnerHeight
			readonly property real full: nodeColumn.implicitHeight
			readonly property real after: {
				let reserved = 0
				if (appHead.visible)
					reserved += column.spacing + appHead.implicitHeight
				if (appPane.appModel.length > 0)
					reserved += column.spacing + Math.min(appPane.full, appPane.rowBlock)
				return reserved
			}
			readonly property real cap: Math.max(0, root.room - Theme.padding - head.implicitHeight - column.spacing - after)
			visible: nodeModel.length > 0
			width: parent.width
			implicitHeight: Math.min(full, Math.max(cap, Math.min(full, rowBlock)))
			height: implicitHeight

			property string scrollPage: root.page
			onScrollPageChanged: nodeFlick.contentY = 0

			Flickable {
				id: nodeFlick
				anchors.fill: parent
				contentWidth: width
				contentHeight: nodeColumn.implicitHeight
				clip: true
				boundsBehavior: Flickable.StopAtBounds
				flickableDirection: Flickable.VerticalFlick
				interactive: contentHeight > height + 1

				Column {
					id: nodeColumn
					width: nodeFlick.width
					spacing: Theme.menuSpacing

					Repeater {
						model: nodePane.nodeModel

						Rectangle {
							id: nodeRow
							required property var modelData
							readonly property bool active: {
								const current = root.page === "microphone" ? AudioState.source : AudioState.sink
								return current && modelData.id === current.id
							}

							width: root.menuWidth - Theme.inset * 2
							x: Theme.inset
							height: Theme.rowInnerHeight
							radius: Theme.rowRadius
							color: nodeHover.containsMouse ? root.ink(active ? Theme.buttonHover : Theme.hover) : (active ? root.ink(Theme.selected) : "transparent")

							Rectangle {
								id: nodeWell
								anchors.left: parent.left
								anchors.leftMargin: 6
								anchors.verticalCenter: parent.verticalCenter
								width: Theme.iconWell
								height: Theme.iconWell
								radius: Theme.buttonRadius
								color: root.ink(Theme.wellFill)

								Text {
									anchors.centerIn: parent
									text: {
										const audio = nodeRow.modelData.audio
										const level = audio ? audio.volume : 0
										const muted = audio ? audio.muted : false
										return root.page === "microphone" ? AudioState.micGlyph(level, muted) : AudioState.volumeGlyph(level, muted)
									}
									color: Theme.foreground
									font.family: Theme.iconFont
									font.pixelSize: Theme.glyphSize
								}
							}

							Text {
								id: nodeStatus
								anchors.right: parent.right
								anchors.rightMargin: 12
								anchors.verticalCenter: parent.verticalCenter
								visible: nodeRow.active
								text: "Active"
								color: Theme.foreground
								font.family: Theme.fontFamily
								font.pixelSize: Theme.smallSize
							}

							Text {
								anchors.left: nodeWell.right
								anchors.leftMargin: Theme.inset
								anchors.right: nodeStatus.left
								anchors.rightMargin: Theme.inset
								anchors.verticalCenter: parent.verticalCenter
								text: AudioState.nodeLabel(nodeRow.modelData)
								color: Theme.foreground
								font.family: Theme.fontFamily
								font.pixelSize: Theme.fontSize
								elide: Text.ElideRight
							}

							MouseArea {
								id: nodeHover
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor
								onClicked: {
									if (root.page === "microphone")
										AudioState.selectSource(nodeRow.modelData)
									else
										AudioState.selectSink(nodeRow.modelData)
								}
							}
						}
					}
				}
			}

			Item {
				id: nodeScroll
				visible: nodeFlick.contentHeight > nodeFlick.height + 1
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.right: parent.right
				width: Theme.inset + Theme.scrollSize

				Rectangle {
					id: nodeThumb
					width: Theme.scrollSize
					radius: width / 2
					anchors.horizontalCenter: parent.horizontalCenter
					color: nodeScrollDrag.containsMouse || nodeScrollDrag.pressed ? Theme.foreground : root.ink(Theme.scroll)
					height: Math.max(24, nodeFlick.height * nodeFlick.height / Math.max(nodeFlick.contentHeight, 1))
					y: nodeFlick.contentY / Math.max(1, nodeFlick.contentHeight - nodeFlick.height) * Math.max(0, nodeFlick.height - height)
				}

				MouseArea {
					id: nodeScrollDrag
					anchors.fill: parent
					hoverEnabled: true
					preventStealing: true
					cursorShape: Qt.PointingHandCursor
					property real origin: 0
					property real originY: 0

					function scrollTo(local) {
						const track = Math.max(1, nodeFlick.height - nodeThumb.height)
						const span = Math.max(0, nodeFlick.contentHeight - nodeFlick.height)
						const barY = Math.max(0, Math.min(track, local - nodeThumb.height / 2))
						nodeFlick.contentY = barY / track * span
					}

					onPressed: mouse => {
						const local = mapToItem(nodePane, mouse.x, mouse.y).y
						const onThumb = local >= nodeThumb.y && local <= nodeThumb.y + nodeThumb.height
						if (!onThumb)
							scrollTo(local)
						origin = local
						originY = nodeFlick.contentY
					}
					onPositionChanged: mouse => {
						if (!pressed)
							return
						const local = mapToItem(nodePane, mouse.x, mouse.y).y
						const track = Math.max(1, nodeFlick.height - nodeThumb.height)
						const span = Math.max(0, nodeFlick.contentHeight - nodeFlick.height)
						nodeFlick.contentY = Math.max(0, Math.min(span, originY + (local - origin) * span / track))
					}
				}
			}
		}

		Column {
			id: appHead
			visible: root.page === "audio" || root.page === "microphone"
			width: parent.width
			spacing: Theme.menuSpacing

			Text {
				visible: root.page === "audio"
				width: parent.width
				text: "Applications"
				color: root.ink(Theme.dim)
				font.family: Theme.fontFamily
				font.pixelSize: Theme.labelSize
				leftPadding: Theme.menuInset
				topPadding: 10
				bottomPadding: 2
			}

			Text {
				visible: root.page === "audio" && AudioState.streamNodes.length === 0
				width: parent.width
				text: AudioState.settled ? "No applications" : "Loading"
				color: root.ink(Theme.muted)
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
				horizontalAlignment: Text.AlignHCenter
				topPadding: 6
				bottomPadding: 6
			}

			Text {
				visible: root.page === "microphone"
				width: parent.width
				text: "Applications"
				color: root.ink(Theme.dim)
				font.family: Theme.fontFamily
				font.pixelSize: Theme.labelSize
				leftPadding: Theme.menuInset
				topPadding: 10
				bottomPadding: 2
			}

			Text {
				visible: root.page === "microphone" && AudioState.captureNodes.length === 0
				width: parent.width
				text: AudioState.settled ? "No applications" : "Loading"
				color: root.ink(Theme.muted)
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
				horizontalAlignment: Text.AlignHCenter
				topPadding: 6
				bottomPadding: 6
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
			readonly property real rowBlock: root.rowHeight + Theme.menuSpacing + Config.audio.sliderSlot
			readonly property real full: appColumn.implicitHeight
			readonly property real budget: {
				let lead = head.implicitHeight
				if (nodePane.visible)
					lead += column.spacing + nodePane.height
				if (appHead.visible)
					lead += column.spacing + appHead.implicitHeight
				lead += column.spacing
				return Math.max(0, root.room - Theme.padding - lead)
			}
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
									anchors.leftMargin: Theme.menuInset
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
									anchors.rightMargin: Theme.menuInset
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
								height: Config.audio.sliderSlot

								VolumeBar {
									anchors.left: parent.left
									anchors.right: parent.right
									anchors.verticalCenter: parent.verticalCenter
									anchors.leftMargin: Theme.menuInset
									anchors.rightMargin: Theme.menuInset
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
				width: Theme.inset + Theme.scrollSize

				Rectangle {
					id: appThumb
					width: Theme.scrollSize
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
