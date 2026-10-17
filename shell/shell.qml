import Quickshell
import qs.osd
import qs.glance
import qs.notifications
import qs.controls
import qs.launcher

ShellRoot {
	property var features: [Osd, Glance, Notifications, Controls, Launcher]

	Ipc {}
}
