pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
	id: root

	property bool paused: false
	readonly property int count: model.count

	function durationOf(notification) {
		const timeout = notification ? notification.expireTimeout : 0
		if (timeout > 0)
			return timeout
		return Theme.notificationHold
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
		if (paused)
			return
		for (let i = model.count - 1; i >= 0; i--) {
			const row = model.get(i)
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
		imageSupported: true
		onNotification: notification => root.track(notification)
	}

	Timer {
		interval: 50
		repeat: true
		running: root.count > 0
		onTriggered: root.tick()
	}
}
