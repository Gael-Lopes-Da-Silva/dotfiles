import QtQuick
import Quickshell.Services.UPower

Item {
	id: root

	property string page: ""
	readonly property int menuWidth: 280
	readonly property int rowHeight: 36
	readonly property real cell: 32

	implicitWidth: menuWidth
	implicitHeight: column.implicitHeight + Theme.padding
	width: implicitWidth
	height: implicitHeight

	property date now: clock.now
	readonly property int today: now.getDate()
	readonly property var cells: monthCells(now)
	readonly property var weekdays: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

	function monthCells(date) {
		const year = date.getFullYear()
		const month = date.getMonth()
		const offset = (new Date(year, month, 1).getDay() + 6) % 7
		const count = new Date(year, month + 1, 0).getDate()
		const cells = []
		for (let i = 0; i < offset; i++)
			cells.push(0)
		for (let day = 1; day <= count; day++)
			cells.push(day)
		while (cells.length % 7 !== 0)
			cells.push(0)
		return cells
	}

	function dim() {
		const color = Theme.foreground
		return Qt.rgba(color.r, color.g, color.b, 0.55)
	}

	QtObject {
		id: clock
		property date now: new Date()
	}

	Timer {
		interval: 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: clock.now = new Date()
	}

	Column {
		id: column
		width: root.menuWidth
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: Theme.padding * 0.5
		spacing: 4

		Item {
			width: parent.width
			height: root.rowHeight
			visible: root.page === "time"

			Text {
				anchors.left: parent.left
				anchors.leftMargin: Theme.padding
				anchors.verticalCenter: parent.verticalCenter
				text: Qt.formatDate(root.now, "MMMM yyyy")
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
			}
		}

		Item {
			width: parent.width
			height: weekdayGrid.implicitHeight
			visible: root.page === "time"

			Grid {
				id: weekdayGrid
				anchors.horizontalCenter: parent.horizontalCenter
				columns: 7

				Repeater {
					model: root.weekdays

					Text {
						required property string modelData
						width: root.cell
						height: 22
						text: modelData
						color: root.dim()
						font.family: Theme.fontFamily
						font.pixelSize: Theme.fontSize - 2
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}
				}
			}
		}

		Item {
			width: parent.width
			height: dayGrid.implicitHeight
			visible: root.page === "time"

			Grid {
				id: dayGrid
				anchors.horizontalCenter: parent.horizontalCenter
				columns: 7

				Repeater {
					model: root.cells

					Item {
						required property var modelData
						width: root.cell
						height: root.cell

						Rectangle {
							anchors.centerIn: parent
							width: 26
							height: 26
							radius: 13
							visible: modelData !== 0 && modelData === root.today
							color: Qt.rgba(Theme.foreground.r, Theme.foreground.g, Theme.foreground.b, 0.16)
						}

						Text {
							anchors.centerIn: parent
							visible: modelData !== 0
							text: modelData
							color: modelData === root.today ? Theme.foreground : root.dim()
							font.family: Theme.fontFamily
							font.pixelSize: Theme.fontSize
							font.bold: modelData === root.today
						}
					}
				}
			}
		}

		Item {
			width: parent.width
			height: root.rowHeight
			visible: root.page === "battery"

			Text {
				anchors.left: parent.left
				anchors.leftMargin: Theme.padding
				anchors.verticalCenter: parent.verticalCenter
				text: "Battery"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
			}

			Text {
				anchors.right: parent.right
				anchors.rightMargin: Theme.padding
				anchors.verticalCenter: parent.verticalCenter
				text: PowerState.percent + "%"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
			}
		}

		Repeater {
			model: root.page === "battery" ? PowerState.profiles : []

			Rectangle {
				id: profileRow
				required property var modelData
				readonly property bool active: PowerProfiles.profile === modelData.profile

				width: root.menuWidth
				height: root.rowHeight
				radius: 8
				color: profileHover.hovered ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

				Text {
					anchors.left: parent.left
					anchors.leftMargin: Theme.padding
					anchors.verticalCenter: parent.verticalCenter
					text: profileRow.modelData.label
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
				}

				Text {
					anchors.right: parent.right
					anchors.rightMargin: Theme.padding
					anchors.verticalCenter: parent.verticalCenter
					visible: profileRow.active
					text: "Active"
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
				}

				HoverHandler {
					id: profileHover
				}

				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: PowerProfiles.profile = profileRow.modelData.profile
				}
			}
		}

		Text {
			visible: root.page === "battery" && PowerState.limitText() !== ""
			width: parent.width
			text: PowerState.limitText()
			color: root.dim()
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize - 1
			wrapMode: Text.WordWrap
			leftPadding: Theme.padding
			rightPadding: Theme.padding
			topPadding: 4
			bottomPadding: 2
		}

		Text {
			visible: root.page === "battery" && !PowerState.plugged
			width: parent.width
			text: PowerState.lifeText()
			color: Theme.foreground
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize
			wrapMode: Text.WordWrap
			leftPadding: Theme.padding
			rightPadding: Theme.padding
			topPadding: 6
			bottomPadding: 6
		}
	}
}
