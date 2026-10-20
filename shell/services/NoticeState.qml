pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.settings

Singleton {
	id: root

	property bool paused: false
	property bool replying: false
	property bool quiet: false
	property int localSeq: 0
	property string lastNotice: ""
	property real lastNoticeAt: 0
	readonly property alias entries: model
	readonly property alias history: historyModel
	readonly property int count: model.count
	readonly property int historyCount: historyModel.count
	readonly property int trackedCount: {
		const tracked = server.trackedNotifications
		return tracked && tracked.values ? tracked.values.length : 0
	}

	function durationOf(notification) {
		const timeout = notification ? notification.expireTimeout : -1
		if (timeout > 0)
			return timeout
		if (timeout === 0)
			return 0
		return Config.notificationHold
	}

	function iconSource(name) {
		const value = String(name || "")
		if (!value)
			return ""
		if (value.indexOf("://") !== -1)
			return value
		if (value.charAt(0) === "/")
			return "file://" + value
		return Quickshell.iconPath(value) || ""
	}

	function markup(text) {
		const allowed = { b: true, i: true, u: true, a: true, img: true, br: true }
		return String(text || "").replace(/\r\n?/g, "\n").replace(/\n/g, "<br/>").replace(/<\/?([a-zA-Z0-9:-]+)(\s[^<>]*)?\s*\/?>/g, (full, name) => {
			return allowed[String(name).toLowerCase()] ? full : ""
		})
	}

	function openLink(url) {
		const value = String(url || "")
		if (!/^(https?:|mailto:|file:)/i.test(value))
			return
		Quickshell.execDetached(["xdg-open", value])
	}

	function copyText(text) {
		Quickshell.clipboardText = String(text || "")
	}

	function logCommand() {
		return "qs log -i " + Quickshell.instanceId
	}

	function trimHistory() {
		while (historyModel.count > Config.noticeHistory)
			historyModel.remove(historyModel.count - 1)
	}

	function remember(entry) {
		for (let i = 0; i < historyModel.count; i++) {
			const row = historyModel.get(i)
			if (row.nid === entry.nid) {
				historyModel.setProperty(i, "app", entry.app)
				historyModel.setProperty(i, "summary", entry.summary)
				historyModel.setProperty(i, "body", entry.body)
				historyModel.setProperty(i, "icon", entry.icon || "")
				historyModel.setProperty(i, "urgent", entry.urgent)
				historyModel.setProperty(i, "at", entry.at)
				historyModel.setProperty(i, "kind", entry.kind || "")
				return
			}
		}
		historyModel.insert(0, entry)
		trimHistory()
	}

	function clearHistory() {
		historyModel.clear()
	}

	function clearEntry(id) {
		for (let i = 0; i < historyModel.count; i++) {
			if (historyModel.get(i).nid === id) {
				historyModel.remove(i)
				return
			}
		}
	}

	function focusSender(notification) {
		if (!notification)
			return
		const keys = []
		const add = value => {
			const key = String(value || "").trim().toLowerCase().replace(/\.desktop$/, "")
			if (key && keys.indexOf(key) === -1)
				keys.push(key)
		}
		add(notification.desktopEntry)
		const entryId = String(notification.desktopEntry || "").replace(/\.desktop$/i, "")
		const entry = entryId ? DesktopEntries.byId(entryId) : null
		if (entry) {
			add(entry.id)
			add(entry.startupClass)
		}
		add(notification.appName)
		if (keys.length === 0)
			return
		const wins = Object.values(NiriState.windows)
		let best = null
		let bestAt = -1
		for (let i = 0; i < wins.length; i++) {
			const win = wins[i]
			const appId = String(win.app_id || "").toLowerCase()
			if (!appId)
				continue
			let matched = false
			for (let k = 0; k < keys.length; k++) {
				const key = keys[k]
				if (appId === key || appId.endsWith("." + key) || key.endsWith("." + appId)) {
					matched = true
					break
				}
			}
			if (!matched)
				continue
			const stamp = win.focus_timestamp && win.focus_timestamp.secs ? win.focus_timestamp.secs : 0
			if (!best || stamp >= bestAt) {
				best = win
				bestAt = stamp
			}
		}
		if (!best)
			return
		Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", String(best.id)])
	}

	function activate(notification) {
		if (!notification)
			return
		focusSender(notification)
		const actions = notification.actions || []
		for (let i = 0; i < actions.length; i++) {
			if (actions[i].identifier === "default") {
				actions[i].invoke()
				return
			}
		}
		notification.dismiss()
	}

	function publish(summary, body, duration, urgent, kind) {
		const key = summary + "\n" + body
		const now = Date.now()
		if (key === lastNotice && now - lastNoticeAt < Config.noticeDedupe)
			return
		lastNotice = key
		lastNoticeAt = now
		const alarm = urgent ? 1 : 0
		const tone = kind || ""
		for (let i = 0; i < model.count; i++) {
			const row = model.get(i)
			if (row.local === 1 && row.summary === summary) {
				model.setProperty(i, "body", body)
				model.setProperty(i, "duration", duration)
				model.setProperty(i, "remaining", duration)
				model.setProperty(i, "urgent", alarm)
				model.setProperty(i, "kind", tone)
				remember({
					nid: row.nid,
					app: Config.shellName,
					summary: summary,
					body: plain(body),
					icon: "",
					at: now,
					urgent: alarm,
					local: 1,
					kind: tone
				})
				return
			}
		}
		localSeq -= 1
		model.append({
			nid: localSeq,
			duration: duration,
			remaining: duration,
			local: 1,
			summary: summary,
			body: body,
			urgent: alarm,
			closing: 0,
			kind: tone
		})
		remember({
			nid: localSeq,
			app: Config.shellName,
			summary: summary,
			body: plain(body),
			icon: "",
			at: now,
			urgent: alarm,
			local: 1,
			kind: tone
		})
	}

	function shellNotice(summary, body, failed) {
		publish(summary, body, failed ? Config.reloadFailHold : Config.reloadHold, failed, "reload")
	}

	function powerNotice(summary, body, urgent) {
		publish(summary, body, Config.notificationHold, urgent, "power")
	}

	function track(notification) {
		if (!notification)
			return
		notification.tracked = true
		const duration = durationOf(notification)
		for (let i = 0; i < model.count; i++) {
			if (model.get(i).nid === notification.id) {
				model.setProperty(i, "duration", duration)
				model.setProperty(i, "remaining", duration)
				return
			}
		}
		model.append({
			nid: notification.id,
			duration: duration,
			remaining: duration,
			local: 0,
			summary: "",
			body: "",
			urgent: 0,
			closing: 0,
			kind: ""
		})
		remember({
			nid: notification.id,
			app: notification.appName || "",
			summary: plain(notification.summary || ""),
			body: notification.body || "",
			icon: iconSource(notification.appIcon || ""),
			at: Date.now(),
			urgent: notification.urgency === NotificationUrgency.Critical ? 1 : 0,
			local: 0,
			kind: ""
		})
		notification.closed.connect(() => root.removeId(notification.id))
	}

	function removeId(id) {
		for (let i = 0; i < model.count; i++) {
			if (model.get(i).nid === id) {
				if (model.get(i).closing === 1)
					return
				model.setProperty(i, "closing", 1)
				return
			}
		}
	}

	function finishRemove(id) {
		for (let i = 0; i < model.count; i++) {
			if (model.get(i).nid === id) {
				model.remove(i)
				return
			}
		}
	}

	function lookup(id) {
		const tracked = server.trackedNotifications
		const list = tracked && tracked.values ? tracked.values : []
		for (let i = 0; i < list.length; i++) {
			if (list[i].id === id)
				return list[i]
		}
		return null
	}

	function plain(text) {
		return String(text || "").replace(/<[^>]+>/g, "")
	}

	function criticalRow(row) {
		if (!row)
			return false
		if (row.local === 1)
			return row.urgent === 1
		const note = lookup(row.nid)
		return !!(note && note.urgency === NotificationUrgency.Critical)
	}

	function tick() {
		if (paused || replying)
			return
		for (let i = model.count - 1; i >= 0; i--) {
			const row = model.get(i)
			if (row.closing === 1)
				continue
			if (!(row.duration > 0))
				continue
			if (quiet && !criticalRow(row))
				continue
			const next = row.remaining - Config.notificationTick
			if (next > 0) {
				model.setProperty(i, "remaining", next)
				continue
			}
			const notification = lookup(row.nid)
			if (notification)
				notification.expire()
			else
				root.removeId(row.nid)
		}
	}

	onQuietChanged: {
		if (quiet)
			return
		for (let i = 0; i < model.count; i++) {
			const row = model.get(i)
			if (row.duration > 0)
				model.setProperty(i, "remaining", row.duration)
		}
	}

	ListModel {
		id: model
	}

	ListModel {
		id: historyModel
	}

	NotificationServer {
		id: server
		bodySupported: true
		bodyMarkupSupported: true
		bodyHyperlinksSupported: true
		bodyImagesSupported: true
		actionsSupported: true
		actionIconsSupported: true
		imageSupported: true
		inlineReplySupported: true
		onNotification: notification => root.track(notification)
	}

	Timer {
		interval: Config.notificationTick
		repeat: true
		running: root.count > 0
		onTriggered: root.tick()
	}

	Connections {
		target: Quickshell

		function onReloadCompleted() {
			Quickshell.inhibitReloadPopup()
			root.shellNotice("Config reloaded", "Run " + root.logCommand() + " to view the log.", false)
		}

		function onReloadFailed(errorString) {
			Quickshell.inhibitReloadPopup()
			root.shellNotice("Config reload failed", errorString, true)
		}
	}
}
