pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
	id: root

	property bool paused: false
	property bool replying: false
	readonly property alias entries: model
	readonly property int count: model.count
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
		return Theme.notificationHold
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
			remaining: duration
		})
		notification.closed.connect(() => root.removeId(notification.id))
	}

	function removeId(id) {
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

	function tick() {
		if (paused || replying)
			return
		for (let i = model.count - 1; i >= 0; i--) {
			const row = model.get(i)
			if (!(row.duration > 0))
				continue
			const next = row.remaining - 50
			if (next > 0) {
				model.setProperty(i, "remaining", next)
				continue
			}
			const notification = lookup(row.nid)
			if (notification)
				notification.expire()
			else
				model.remove(i)
		}
	}

	ListModel {
		id: model
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
		interval: 50
		repeat: true
		running: root.count > 0
		onTriggered: root.tick()
	}
}
