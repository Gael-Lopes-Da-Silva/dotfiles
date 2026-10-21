// Month calendar shown from the status chip. Options live in config.json "clock".
import QtQuick
import qs.lib

Column {
	id: root

	spacing: 2

	property date now: clock.now
	readonly property int today: now.getDate()
	readonly property var cells: monthCells(now)
	readonly property var weekdays: Config.clock.weekdays
	readonly property real cell: Config.clock.cell

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
		interval: Config.status.tick
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: clock.now = new Date()
	}

		Item {
			width: parent.width
			height: 52

			Text {
				id: monthTitle
				anchors.left: parent.left
				anchors.leftMargin: 18
				anchors.top: parent.top
				anchors.topMargin: 4
				text: Qt.formatDate(root.now, Config.clock.monthFormat)
				color: Theme.foreground
				font.family: Theme.fontFamily
				font.pixelSize: Config.clock.monthSize
			}

			Text {
				anchors.left: monthTitle.right
				anchors.leftMargin: 8
				anchors.baseline: monthTitle.baseline
				text: Qt.formatDate(root.now, Config.clock.yearFormat)
				color: root.ink(Theme.muted)
				font.family: Theme.fontFamily
				font.pixelSize: Config.clock.yearSize
			}

			Text {
				anchors.left: parent.left
				anchors.leftMargin: 18
				anchors.top: monthTitle.bottom
				text: Qt.formatDate(root.now, Config.clock.weekdayFormat)
				color: root.ink(Theme.iconMuted)
				font.family: Theme.fontFamily
				font.pixelSize: Theme.smallSize
			}
		}

		Item {
			width: parent.width
			height: weekdayGrid.implicitHeight

			Grid {
				id: weekdayGrid
				anchors.horizontalCenter: parent.horizontalCenter
				columns: 7

				Repeater {
					model: root.weekdays

					Text {
						required property string modelData
						width: root.cell
						height: Config.clock.weekdayHeight
						text: modelData
						color: root.ink(Theme.dim)
						font.family: Theme.fontFamily
						font.pixelSize: Theme.labelSize
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
							width: Config.clock.todaySize
							height: Config.clock.todaySize
							radius: Config.clock.todaySize / 2
							visible: dayCell.current
							color: Theme.foreground
						}

						Text {
							anchors.centerIn: parent
							visible: modelData !== 0
							text: modelData
							color: dayCell.current ? Theme.background : root.ink(Theme.body)
							font.family: Theme.fontFamily
							font.pixelSize: Theme.fontSize
							font.bold: dayCell.current
						}
					}
				}
			}
		}
}
