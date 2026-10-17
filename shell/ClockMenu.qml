import QtQuick
import Quickshell.Services.UPower

Item {
	id: root

	property string page: ""
	readonly property int menuWidth: 292
	readonly property int rowHeight: 44
	readonly property real cell: 36

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

	function ink(alpha) {
		return Theme.ink(alpha)
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
		anchors.topMargin: 8
		spacing: 2

		Item {
			width: parent.width
			height: 52
			visible: root.page === "time"

			Text {
				id: monthTitle
				anchors.left: parent.left
				anchors.leftMargin: 18
				anchors.top: parent.top
				anchors.topMargin: 4
				text: Qt.formatDate(root.now, "MMMM")
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize + 8
			}

			Text {
				anchors.left: monthTitle.right
				anchors.leftMargin: 8
				anchors.baseline: monthTitle.baseline
				text: Qt.formatDate(root.now, "yyyy")
				color: root.ink(0.45)
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize + 2
			}

			Text {
				anchors.left: parent.left
				anchors.leftMargin: 18
				anchors.top: monthTitle.bottom
				text: Qt.formatDate(root.now, "dddd")
				color: root.ink(0.55)
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize - 1
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
						height: 24
						text: modelData
						color: root.ink(0.4)
						font.family: Theme.fontFamily
						font.pixelSize: Theme.fontSize - 2
						font.letterSpacing: 0.4
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}
				}
			}
		}

		Item {
			width: parent.width
			height: dayGrid.implicitHeight + 8
			visible: root.page === "time"

			Grid {
				id: dayGrid
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				columns: 7

				Repeater {
					model: root.cells

					Item {
						id: dayCell
						required property var modelData
						readonly property bool current: modelData !== 0 && modelData === root.today

						width: root.cell
						height: root.cell

						Rectangle {
							anchors.centerIn: parent
							width: 30
							height: 30
							radius: 15
							visible: dayCell.current
							color: Theme.foreground
						}

						Text {
							anchors.centerIn: parent
							visible: modelData !== 0
							text: modelData
							color: dayCell.current ? Theme.background : root.ink(0.82)
							font.family: Theme.fontFamily
							font.pixelSize: Theme.fontSize
							font.bold: dayCell.current
						}
					}
				}
			}
		}

		Item {
			width: parent.width
			height: 64
			visible: root.page === "battery"

			Text {
				id: batteryTitle
				anchors.left: parent.left
				anchors.leftMargin: 18
				anchors.top: parent.top
				anchors.topMargin: 6
				text: "Battery"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize + 4
			}

			Text {
				anchors.right: parent.right
				anchors.rightMargin: 18
				anchors.baseline: batteryTitle.baseline
				text: PowerState.percent + "%"
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize + 4
			}

			Rectangle {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.leftMargin: 18
				anchors.rightMargin: 18
				anchors.bottom: parent.bottom
				anchors.bottomMargin: 10
				height: 6
				radius: 3
				color: root.ink(0.16)

				Rectangle {
					width: parent.width * Math.max(0, Math.min(1, PowerState.level))
					height: parent.height
					radius: parent.radius
					color: PowerState.percent <= 15 && !PowerState.plugged ? Theme.recording : Theme.foreground
				}
			}
		}

		Item {
			visible: root.page === "battery" && !PowerState.plugged
			width: parent.width
			height: life.implicitHeight + 16

			Rectangle {
				anchors.fill: parent
				anchors.leftMargin: 8
				anchors.rightMargin: 8
				radius: 10
				color: root.ink(0.06)
			}

			Text {
				id: life
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				anchors.leftMargin: 18
				anchors.rightMargin: 18
				text: PowerState.lifeText()
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Theme.fontSize
				wrapMode: Text.WordWrap
			}
		}

		Repeater {
			model: root.page === "battery" ? PowerState.profiles : []

			Rectangle {
				id: profileRow
				required property var modelData
				readonly property bool active: PowerProfiles.profile === modelData.profile

				width: root.menuWidth - 16
				x: 8
				height: 40
				radius: 10
				color: active ? root.ink(0.14) : profileHover.hovered ? root.ink(0.07) : "transparent"

				Text {
					anchors.left: parent.left
					anchors.leftMargin: 14
					anchors.verticalCenter: parent.verticalCenter
					text: profileRow.modelData.label
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize
				}

				Text {
					anchors.right: parent.right
					anchors.rightMargin: 14
					anchors.verticalCenter: parent.verticalCenter
					visible: profileRow.active
					text: "Active"
					color: Theme.foreground
					font.family: Theme.fontFamily
					font.pixelSize: Theme.fontSize - 1
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
			color: root.ink(0.5)
			font.family: Theme.fontFamily
			font.pixelSize: Theme.fontSize - 1
			wrapMode: Text.WordWrap
			leftPadding: 18
			rightPadding: 18
			topPadding: 6
			bottomPadding: 2
		}
	}
}
