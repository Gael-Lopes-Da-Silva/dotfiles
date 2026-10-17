import QtQuick

Item {
	id: root

	property string mode: "recording"

	implicitWidth: icon.implicitWidth + Theme.padding * 2
	implicitHeight: icon.implicitHeight + Theme.padding * 2

	Text {
		id: icon
		anchors.centerIn: parent
		text: String.fromCodePoint(root.mode === "casting" ? 0xF0118 : 0xF0EC2)
		color: Theme.recording
		font.family: Theme.iconFont
		font.pixelSize: Theme.clockSize
	}
}
