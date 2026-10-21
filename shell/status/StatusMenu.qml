// Menu under the status chip. Shows the calendar, the battery page, or the notice center.
import QtQuick
import qs.battery
import qs.clock
import qs.notices
import qs.settings

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

		Calendar {
			width: parent.width
			visible: root.page === "time"
		}

		NoticeCenter {
			width: parent.width
			visible: root.page === "notices"
			maxHeight: Math.max(Theme.rowHeight * 3, root.room - 8 - Theme.padding)
		}

		BatteryMenu {
			width: parent.width
			visible: root.page === "battery"
		}
	}
}
