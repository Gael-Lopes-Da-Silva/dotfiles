// Background layer behind the frame. Clicks pass through to the desktop.
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
	id: root

	anchors.left: true
	anchors.right: true
	anchors.top: true
	anchors.bottom: true

	exclusionMode: ExclusionMode.Ignore
	color: "black"
	WlrLayershell.layer: WlrLayer.Background
	WlrLayershell.namespace: "wallpaper"
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

	// Empty mask: clicks fall through to the desktop.
	mask: Region {}

	Image {
		anchors.fill: parent
		source: Qt.resolvedUrl("../wallpaper.png")
		fillMode: Image.PreserveAspectCrop
		asynchronous: true
		cache: true
		smooth: true
		sourceSize.width: Math.round(width * root.devicePixelRatio)
		sourceSize.height: Math.round(height * root.devicePixelRatio)
	}
}
