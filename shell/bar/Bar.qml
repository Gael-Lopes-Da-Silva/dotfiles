import Quickshell
import QtQuick
import qs

Scope {
	Variants {
		model: Quickshell.screens

		PanelWindow {
			required property var modelData

			screen: modelData
			color: Theme.background
			implicitHeight: Theme.barHeight

			anchors {
				top: true
				left: true
				right: true
			}

			Clock {
				anchors.centerIn: parent
			}

			Rectangle {
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				height: 1
				color: Theme.border
			}
		}
	}
}
