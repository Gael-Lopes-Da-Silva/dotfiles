pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	property string outputName: ""
	property var workspaces: ({})

	readonly property var screen: {
		const name = outputName
		const screens = Quickshell.screens
		for (let i = 0; i < screens.length; i++) {
			if (screens[i].name === name)
				return screens[i]
		}
		return screens.length > 0 ? screens[0] : null
	}

	function ingest(line) {
		let event
		try {
			event = JSON.parse(line)
		} catch (error) {
			return
		}

		if (event.WorkspacesChanged) {
			const next = {}
			let focused = ""
			const list = event.WorkspacesChanged.workspaces || []
			for (let i = 0; i < list.length; i++) {
				const workspace = list[i]
				next[workspace.id] = workspace.output || ""
				if (workspace.is_focused && workspace.output)
					focused = workspace.output
			}
			workspaces = next
			if (focused)
				outputName = focused
		} else if (event.WorkspaceActivated && event.WorkspaceActivated.focused) {
			const output = workspaces[event.WorkspaceActivated.id]
			if (output)
				outputName = output
		}
	}

	function connect() {
		const path = Quickshell.env("NIRI_SOCKET") || ""
		socket.path = path
		socket.connected = path.length > 0
	}

	Socket {
		id: socket
		onConnectionStateChanged: {
			if (connected)
				write('{"EventStream":null}\n')
		}
		onError: retry.restart()
		parser: SplitParser {
			onRead: line => Focus.ingest(line)
		}
	}

	Timer {
		id: retry
		interval: 1000
		onTriggered: Focus.connect()
	}

	Component.onCompleted: connect()
}
