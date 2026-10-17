import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

Item {
	id: root

	property string lifetime: "transient"
	property string edge: "bottom"
	property bool wantsKeyboard: false
	property bool timed: true
	property int timeout: Theme.osdTimeout
	property string namespace: "shell"
	property bool shown: false
	property Component content

	readonly property bool session: lifetime === "session"

	function summon() {
		if (session)
			Sessions.claim(root)
		shown = true
		if (timed)
			hideTimer.restart()
	}

	function dismiss() {
		shown = false
		hideTimer.stop()
		if (session)
			Sessions.release(root)
	}

	Timer {
		id: hideTimer
		interval: root.timeout
		onTriggered: root.dismiss()
	}

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: window

			required property var modelData

			readonly property bool active: root.shown && Focus.screen && modelData.name === Focus.screen.name
			readonly property int boxWidth: plate.item ? Math.max(1, plate.item.implicitWidth) : 1
			readonly property int boxHeight: plate.item ? Math.max(1, plate.item.implicitHeight) : 1
			readonly property int sideMargin: Math.max(0, Math.round((modelData.width - boxWidth) / 2))
			readonly property int verticalMargin: Math.max(0, Math.round((modelData.height - boxHeight) / 2))

			property bool live: false

			screen: modelData
			color: "transparent"
			exclusionMode: ExclusionMode.Ignore
			visible: live
			implicitWidth: boxWidth
			implicitHeight: boxHeight

			WlrLayershell.namespace: root.namespace
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: active && root.wantsKeyboard ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

			anchors {
				left: true
				right: true
				top: root.session || root.edge !== "bottom"
				bottom: root.session || root.edge !== "top"
			}

			margins {
				left: root.session ? 0 : sideMargin
				right: root.session ? 0 : sideMargin
				top: root.session ? 0 : root.edge === "top" ? 24 : root.edge === "center" ? verticalMargin : 0
				bottom: root.session ? 0 : root.edge === "bottom" ? 32 : root.edge === "center" ? verticalMargin : 0
			}

			onActiveChanged: {
				if (active) {
					live = true
					if (root.wantsKeyboard)
						Qt.callLater(plate.forceActiveFocus)
				}
			}

			MouseArea {
				anchors.fill: parent
				enabled: root.session && window.active
				onClicked: root.dismiss()
			}

			Shortcut {
				enabled: window.active && root.session
				sequence: "Escape"
				context: Qt.WindowShortcut
				onActivated: root.dismiss()
			}

			Item {
				id: host
				z: 1
				anchors.centerIn: parent
				width: window.boxWidth
				height: window.boxHeight
				opacity: window.active ? 1 : 0
				property real shift: window.active ? 0 : root.edge === "top" ? -Theme.travel : Theme.travel

				transform: Translate {
					y: host.shift
				}

				Behavior on opacity {
					NumberAnimation {
						duration: Theme.fade
					}
				}

				Behavior on shift {
					NumberAnimation {
						duration: Theme.fade
					}
				}

				onOpacityChanged: {
					if (opacity === 0 && !window.active)
						window.live = false
				}

				MouseArea {
					anchors.fill: parent
				}

				Loader {
					id: plate
					anchors.fill: parent
					sourceComponent: root.content
					focus: true
				}
			}
		}
	}
}
