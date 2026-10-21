// Menu under the status chip. Shows the calendar, the battery page, or the notice center.
import QtQuick
import qs.components.notifications
import qs.lib

Item {
	id: root

	property string page: ""
	property real room: 640

	// The notice history is wider than the calendar.
	readonly property int menuWidth: page === "notices" ? Config.notices.popupWidth : Config.status.menuWidth

	implicitWidth: menuWidth
	implicitHeight: column.implicitHeight + Theme.padding
	width: implicitWidth
	height: implicitHeight

	Column {
		id: column
		width: root.menuWidth
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.top: parent.top
		anchors.topMargin: 8
		spacing: 0

		Loader {
			id: timePage
			width: parent.width
			active: root.page === "time"
			asynchronous: false
			height: item ? item.implicitHeight : 0

			sourceComponent: Component {
				Calendar {
					width: timePage.width
				}
			}
		}

		Loader {
			id: noticePage
			width: parent.width
			active: root.page === "notices"
			asynchronous: false
			height: item ? item.implicitHeight : 0

			sourceComponent: Component {
				NoticeCenter {
					width: noticePage.width
					maxHeight: Math.max(Theme.rowHeight * 3, root.room - 8 - Theme.padding)
				}
			}
		}

		Loader {
			id: batteryPage
			width: parent.width
			active: root.page === "battery"
			asynchronous: false
			height: item ? item.implicitHeight : 0

			sourceComponent: Component {
				BatteryMenu {
					width: batteryPage.width
				}
			}
		}
	}
}
