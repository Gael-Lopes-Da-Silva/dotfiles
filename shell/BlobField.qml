import QtQuick

Item {
	id: root

	property real thickness: 0
	property real radius: 0
	property real smoothing: 24
	property color color: "#242424"
	property vector4d panel0: Qt.vector4d(0, 0, 0, 0)
	property vector4d panel1: Qt.vector4d(0, 0, 0, 0)
	property vector4d panel2: Qt.vector4d(0, 0, 0, 0)
	property vector4d panel3: Qt.vector4d(0, 0, 0, 0)
	property vector4d panel4: Qt.vector4d(0, 0, 0, 0)
	property vector4d panelRadius: Qt.vector4d(0, 0, 0, 0)
	property real panel4Radius: 0

	ShaderEffect {
		anchors.fill: parent
		blending: true
		fragmentShader: Qt.resolvedUrl("frame.frag.qsb")

		property real fieldWidth: width
		property real fieldHeight: height
		property real thickness: root.thickness
		property real radius: root.radius
		property real smoothing: root.smoothing
		property vector4d panel0: root.panel0
		property vector4d panel1: root.panel1
		property vector4d panel2: root.panel2
		property vector4d panel3: root.panel3
		property vector4d panelRadius: root.panelRadius
		property color surface: root.color
		property vector4d panel4: root.panel4
		property real panel4Radius: root.panel4Radius
	}
}


