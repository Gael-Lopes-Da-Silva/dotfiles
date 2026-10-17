import QtQuick
import qs

Rectangle {
	id: root

	property string text
	signal clicked

	implicitWidth: label.implicitWidth + 16
	implicitHeight: label.implicitHeight + 8
	radius: 8
	color: area.containsMouse ? Theme.border : "transparent"

	Text {
		id: label
		anchors.centerIn: parent
		text: root.text
		color: Theme.foreground
		font.family: Theme.fontFamily
		font.pixelSize: Theme.fontSize
	}

	MouseArea {
		id: area
		anchors.fill: parent
		hoverEnabled: true
		onClicked: root.clicked()
	}
}
