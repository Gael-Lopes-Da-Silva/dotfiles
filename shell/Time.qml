pragma Singleton

import Quickshell
import QtQuick

Singleton {
	readonly property string text: Qt.formatDateTime(clock.date, "ddd d MMM  HH:mm")

	SystemClock {
		id: clock
		precision: SystemClock.Minutes
	}
}
