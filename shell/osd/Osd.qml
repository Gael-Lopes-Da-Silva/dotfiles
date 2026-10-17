pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import qs
import qs.common

Item {
	id: osd

	property string icon: ""
	property string label: ""
	property real level: -1

	function show(icon, label, level) {
		osd.icon = icon
		osd.label = label
		osd.level = level
		surface.summon()
	}

	function sink() {
		const node = Pipewire.defaultAudioSink
		return node && node.audio ? node.audio : null
	}

	function source() {
		const node = Pipewire.defaultAudioSource
		return node && node.audio ? node.audio : null
	}

	function presentSink() {
		const audio = sink()
		if (!audio)
			return
		if (audio.muted)
			show("\uf6a9", "Muted", -1)
		else if (audio.volume < 0.01)
			show("\uf026", "0%", 0)
		else
			show("\uf028", Math.round(audio.volume * 100) + "%", audio.volume)
	}

	function raiseVolume() {
		const audio = sink()
		if (!audio)
			return
		if (audio.volume < 1)
			audio.volume = Math.min(1, audio.volume + 0.1)
		presentSink()
	}

	function lowerVolume() {
		const audio = sink()
		if (!audio)
			return
		audio.volume = Math.max(0, audio.volume - 0.1)
		presentSink()
	}

	function mute() {
		const audio = sink()
		if (!audio)
			return
		audio.muted = !audio.muted
		presentSink()
	}

	function muteSource() {
		const audio = source()
		if (!audio)
			return
		audio.muted = !audio.muted
		show(audio.muted ? "\uf131" : "\uf130", audio.muted ? "Microphone off" : "Microphone on", -1)
	}

	function brightness(argument) {
		if (backlight.running) {
			backlight.queued = argument
			return
		}
		backlight.queued = ""
		backlight.exec(["brightnessctl", "--class=backlight", "-m", "set", argument])
	}

	function brightnessUp() {
		brightness("+10%")
	}

	function brightnessDown() {
		brightness("10%-")
	}

	function player() {
		const players = Mpris.players.values
		for (let i = 0; i < players.length; i++) {
			if (players[i].isPlaying)
				return players[i]
		}
		return players.length > 0 ? players[0] : null
	}

	function track(target) {
		if (!target)
			return "Nothing playing"
		const title = target.trackTitle || "Unknown"
		const artist = target.trackArtist || ""
		return artist ? title + "  ·  " + artist : title
	}

	function presentPlayer(target, icon) {
		media.icon = icon
		media.target = target
		media.restart()
	}

	function playPause() {
		const target = player()
		if (!target) {
			show("\uf04b", "Nothing playing", -1)
			return
		}
		const icon = target.isPlaying ? "\uf04c" : "\uf04b"
		target.togglePlaying()
		presentPlayer(target, icon)
	}

	function stop() {
		const target = player()
		if (!target) {
			show("\uf04d", "Nothing playing", -1)
			return
		}
		target.stop()
		presentPlayer(target, "\uf04d")
	}

	function previous() {
		const target = player()
		if (!target) {
			show("\uf04a", "Nothing playing", -1)
			return
		}
		target.previous()
		presentPlayer(target, "\uf04a")
	}

	function next() {
		const target = player()
		if (!target) {
			show("\uf04e", "Nothing playing", -1)
			return
		}
		target.next()
		presentPlayer(target, "\uf04e")
	}

	PwObjectTracker {
		objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
	}

	Process {
		id: backlight
		property string queued: ""
		stdout: StdioCollector {
			id: backlightOut
			waitForEnd: true
		}
		onExited: exitCode => {
			if (exitCode === 0) {
				const line = backlightOut.text.trim().split("\n").pop()
				const percent = parseInt(line.split(",")[3], 10)
				if (!isNaN(percent))
					osd.show("\uf185", percent + "%", percent / 100)
			}
			if (queued.length > 0) {
				const argument = queued
				queued = ""
				exec(["brightnessctl", "--class=backlight", "-m", "set", argument])
			}
		}
	}

	Timer {
		id: media
		interval: 200
		property var target: null
		property string icon: ""
		onTriggered: osd.show(icon, osd.track(target), -1)
	}

	Surface {
		id: surface
		lifetime: "transient"
		edge: "bottom"
		namespace: "osd"
		timeout: Theme.osdTimeout

		content: Rectangle {
			implicitWidth: Math.max(240, row.implicitWidth + Theme.padding * 2)
			implicitHeight: row.implicitHeight + Theme.padding * 2
			radius: Theme.radius
			color: Theme.background
			border.color: Theme.border
			border.width: 1

			Row {
				id: row
				anchors.centerIn: parent
				spacing: Theme.gap

				Text {
					anchors.verticalCenter: parent.verticalCenter
					text: osd.icon
					color: Theme.foreground
					font.family: Theme.iconFont
					font.pixelSize: Theme.fontSize + 6
				}

				Column {
					spacing: 8

					Text {
						width: Math.min(260, implicitWidth)
						text: osd.label
						color: Theme.foreground
						font.family: Theme.fontFamily
						font.pixelSize: Theme.fontSize
						elide: Text.ElideRight
					}

					Rectangle {
						visible: osd.level >= 0
						width: 160
						height: 4
						radius: 2
						color: Theme.border

						Rectangle {
							width: parent.width * Math.max(0, Math.min(1, osd.level))
							height: parent.height
							radius: 2
							color: Theme.foreground
						}
					}
				}
			}
		}
	}
}
