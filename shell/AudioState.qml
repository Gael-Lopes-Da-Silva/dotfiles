pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
	id: root

	property bool primed: false
	property real volume: 0
	property bool muted: false

	Timer {
		interval: 500
		running: true
		onTriggered: {
			if (root.liveVolume >= 0) {
				root.volume = root.liveVolume
				root.muted = root.liveMuted
			}
			root.primed = true
		}
	}

	readonly property var sinkAudio: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
	readonly property real liveVolume: sinkAudio ? sinkAudio.volume : -1
	readonly property bool liveMuted: sinkAudio ? sinkAudio.muted : false

	PwObjectTracker {
		objects: [Pipewire.defaultAudioSink]
	}

	onLiveVolumeChanged: note()
	onLiveMutedChanged: note()

	function note() {
		if (!primed || liveVolume < 0)
			return
		const changed = Math.abs(liveVolume - volume) > 0.005 || liveMuted !== muted
		volume = liveVolume
		muted = liveMuted
		if (changed)
			NiriState.showOsd("volume")
	}
}
