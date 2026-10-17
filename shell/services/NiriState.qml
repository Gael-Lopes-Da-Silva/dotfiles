pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs

Singleton {
	id: root

	property var workspaces: []
	property var windows: ({})
	property var casts: ({})
	property int revision: 0

	property bool launcherOpen: false
	property string launcherOutput: ""
	property bool hidden: false

	property string osdKind: ""
	property string osdText: ""
	property bool osdOn: true
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
		if (screenWidth < Config.fullscreenMin || screenHeight < Config.fullscreenMin)
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
			if (Math.abs(tile[0] - screenWidth) <= Config.fullscreenSlack && Math.abs(tile[1] - screenHeight) <= Config.fullscreenSlack)
				return true
		}
		return false
	}

	function bump() {
		revision++
	}

	function toggleLauncher() {
		if (hidden)
			hidden = false
		if (launcherOpen) {
			closeLauncher()
			return
		}
		launcherOutput = focusedOutput
		launcherOpen = true
		osdOpen = false
	}

	function toggleHidden() {
		hidden = !hidden
		if (!hidden)
			return
		closeLauncher()
		osdOpen = false
		NoticeState.replying = false
		PowerState.closeMenu()
		RadioState.closeMenu()
	}

	function closeLauncher() {
		launcherOpen = false
		if (osdTimer.running)
			osdOpen = true
	}

	function castIsLive(cast) {
		if (!cast)
			return false
		const target = cast.target || {}
		return cast.is_active === true || !!target.Output || !!target.Window
	}

	function castAffects(cast, outputName) {
		if (!castIsLive(cast))
			return false
		const target = cast.target || {}
		if (target.Output)
			return target.Output.name === outputName
		if (target.Window) {
			const win = windows[target.Window.id]
			if (!win)
				return true
			for (let w = 0; w < workspaces.length; w++) {
				if (workspaces[w].id === win.workspace_id)
					return workspaces[w].output === "" || workspaces[w].output === outputName
			}
			return true
		}
		return true
	}

	function castMode(outputName) {
		const _ = revision
		let recording = false
		let casting = false
		const values = Object.values(casts)
		for (let i = 0; i < values.length; i++) {
			const cast = values[i]
			if (!castAffects(cast, outputName))
				continue
			const target = cast.target || {}
			if (target.Window && !target.Output)
				casting = true
			else
				recording = true
		}
		if (recording)
			return "recording"
		if (casting)
			return "casting"
		return ""
	}

	function stopCasts(outputName) {
		const seen = {}
		const values = Object.values(casts)
		for (let i = 0; i < values.length; i++) {
			const cast = values[i]
			if (!castAffects(cast, outputName) || cast.kind !== "PipeWire")
				continue
			const id = cast.session_id
			if (id === undefined || id === null || seen[id])
				continue
			seen[id] = true
			Quickshell.execDetached(["niri", "msg", "action", "stop-cast", "--session-id", String(id)])
		}
	}

	function showOsd(kind, text, on) {
		if (hidden)
			return
		osdKind = kind
		osdText = text || ""
		osdOn = on !== false
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
		} else if (event.CastsChanged) {
			const next = {}
			const list = event.CastsChanged.casts || []
			for (let i = 0; i < list.length; i++)
				next[list[i].stream_id] = list[i]
			casts = next
		} else if (event.CastStartedOrChanged) {
			const cast = event.CastStartedOrChanged.cast
			const next = Object.assign({}, casts)
			next[cast.stream_id] = cast
			casts = next
		} else if (event.CastStopped) {
			const next = Object.assign({}, casts)
			delete next[event.CastStopped.stream_id]
			casts = next
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
		interval: Config.niriRetry
		onTriggered: stream.running = true
	}

	Timer {
		id: osdTimer
		interval: Config.osdHold
		onTriggered: root.osdOpen = false
	}
}
