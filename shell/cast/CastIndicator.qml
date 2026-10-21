// Recording indicator in the top-left corner while a cast is active.
import QtQuick
import qs.settings

Item {
	implicitWidth: icon.implicitWidth + Theme.padding * 2
	implicitHeight: icon.implicitHeight + Theme.padding * 2

	Text {
		id: icon
		anchors.centerIn: parent
		text: Config.icon(Config.cast.icon)
		color: Theme.recording
		font.family: Theme.iconFont
		font.pixelSize: Theme.iconSize
	}
}
