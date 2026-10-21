// On/off switch used by the wifi and bluetooth headers and the notice-center quiet control.
import QtQuick
import qs.settings

Item {
	id: root

	property bool on: false

	implicitWidth: Theme.toggleWidth
	implicitHeight: Theme.toggleHeight

	Rectangle {
		anchors.fill: parent
		radius: height / 2
		color: root.on ? Theme.foreground : Theme.ink(Theme.track)
	}

	Rectangle {
		width: Theme.toggleKnob
		height: Theme.toggleKnob
		radius: Theme.toggleKnob / 2
		anchors.verticalCenter: parent.verticalCenter
		x: root.on ? parent.width - width - Theme.toggleInset : Theme.toggleInset
		color: root.on ? Theme.background : Theme.foreground
	}
}
