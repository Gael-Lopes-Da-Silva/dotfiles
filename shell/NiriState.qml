pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	property var workspaces: []
	property var windows: ({})
	property int revision: 0

	property bool launcherOpen: false
	property string launcherOutput: ""

	property string osdKind: ""
	property bool osdOpen: false

	readonly property string focusedOutput: {
		const _ = revision
		for (let i = 0; i < workspaces.length; i++) {
			const ws = workspaces[i]
			if (ws.is_focused && ws.output)
				return ws.output
		}
		return ""
	}

	function isFullscreen(name, screenWidth, screenHeight) {
		if (screenWidth < 100 || screenHeight < 100)
			return false

		let active = null
		for (let i = 0; i < workspaces.length; i++) {
			const ws = workspaces[i]
			if (ws.output === name && ws.is_active) {
				active = ws
				break
			}
		}
		if (!active)
			return false

		const values = Object.values(windows)
		for (let i = 0; i < values.length; i++) {
			const win = values[i]
			if (win.workspace_id !== active.id)
				continue
			if (win.is_fullscreen === true)
				return true
			const tile = win.layout && win.layout.tile_size
			if (!tile)
				continue
			if (Math.abs(tile[0] - screenWidth) <= 8 && Math.abs(tile[1] - screenHeight) <= 8)
				return true
		}
		return false
	}

	function bump() {
		revision++
	}

	function toggleLauncher() {
		if (launcherOpen) {
			closeLauncher()
			return
		}
		launcherOutput = focusedOutput
		launcherOpen = true
		osdOpen = false
	}

	function closeLauncher() {
		launcherOpen = false
		if (osdTimer.running)
			osdOpen = true
	}

	function showOsd(kind) {
		osdKind = kind
		if (!launcherOpen)
			osdOpen = true
		osdTimer.restart()
	}

	function ingest(line) {
		let event
		try {
			event = JSON.parse(line)
		} catch (e) {
			return
		}

		if (event.WorkspacesChanged) {
			workspaces = event.WorkspacesChanged.workspaces
		} else if (event.WorkspaceActivated) {
			const id = event.WorkspaceActivated.id
			const focused = event.WorkspaceActivated.focused
			let output = ""
			for (let i = 0; i < workspaces.length; i++) {
				if (workspaces[i].id === id)
					output = workspaces[i].output
			}
			const next = []
			for (let i = 0; i < workspaces.length; i++) {
				const ws = workspaces[i]
				const sameOutput = output !== "" && ws.output === output
				next.push(Object.assign({}, ws, {
					is_active: ws.id === id ? true : (sameOutput ? false : ws.is_active),
					is_focused: focused ? ws.id === id : (ws.id === id ? false : ws.is_focused)
				}))
			}
			workspaces = next
		} else if (event.WindowsChanged) {
			const next = {}
			const list = event.WindowsChanged.windows
			for (let i = 0; i < list.length; i++)
				next[list[i].id] = list[i]
			windows = next
		} else if (event.WindowOpenedOrChanged) {
			const win = event.WindowOpenedOrChanged.window
			const next = Object.assign({}, windows)
			if (win.is_focused) {
				const keys = Object.keys(next)
				for (let i = 0; i < keys.length; i++) {
					const key = keys[i]
					if (Number(key) !== win.id && next[key].is_focused)
						next[key] = Object.assign({}, next[key], { is_focused: false })
				}
			}
			next[win.id] = win
			windows = next
		} else if (event.WindowClosed) {
			const next = Object.assign({}, windows)
			delete next[event.WindowClosed.id]
			windows = next
		} else if (event.WindowFocusChanged) {
			const id = event.WindowFocusChanged.id
			const next = {}
			const keys = Object.keys(windows)
			for (let i = 0; i < keys.length; i++) {
				const key = keys[i]
				const win = windows[key]
				next[key] = Object.assign({}, win, {
					is_focused: id !== null && id !== undefined && Number(key) === id
				})
			}
			windows = next
		} else if (event.WindowLayoutsChanged) {
			const next = Object.assign({}, windows)
			const changes = event.WindowLayoutsChanged.changes
			for (let i = 0; i < changes.length; i++) {
				const id = changes[i][0]
				const layout = changes[i][1]
				if (next[id])
					next[id] = Object.assign({}, next[id], { layout: layout })
			}
			windows = next
		} else {
			return
		}

		bump()
	}

	Process {
		id: stream
		command: ["niri", "msg", "--json", "event-stream"]
		running: true
		stdout: SplitParser {
			onRead: line => root.ingest(String(line))
		}
		onExited: retry.restart()
	}

	Timer {
		id: retry
		interval: 1000
		onTriggered: stream.running = true
	}

	Timer {
		id: osdTimer
		interval: Theme.osdHold
		onTriggered: root.osdOpen = false
	}
}
