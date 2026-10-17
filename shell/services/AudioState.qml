pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs

Singleton {
	id: root

	property bool primed: false
	property bool adjusting: false
	property bool micAdjusting: false
	property real volume: 0
	property bool muted: false
	property real micVolume: 0
	property bool micMuted: false
	property var sinkNodes: []
	property var sourceNodes: []
	property var streamNodes: []
	property var captureNodes: []

	readonly property var sink: Pipewire.defaultAudioSink
	readonly property var source: Pipewire.defaultAudioSource
	readonly property var sinkAudio: sink ? sink.audio : null
	readonly property real liveVolume: sinkAudio ? sinkAudio.volume : -1
	readonly property bool liveMuted: sinkAudio ? sinkAudio.muted : false
	readonly property real sinkLevel: sinkAudio ? sinkAudio.volume : 0
	readonly property bool sinkMuted: sinkAudio ? sinkAudio.muted : false
	readonly property var sourceAudio: source ? source.audio : null
	readonly property real sourceLevel: sourceAudio ? sourceAudio.volume : 0
	readonly property bool sourceMuted: sourceAudio ? sourceAudio.muted : false

	readonly property var tracked: {
		const list = []
		const seen = {}
		function add(node) {
			if (!node || seen[node.id])
				return
			seen[node.id] = true
			list.push(node)
		}
		add(sink)
		add(source)
		for (let i = 0; i < sinkNodes.length; i++)
			add(sinkNodes[i])
		for (let i = 0; i < sourceNodes.length; i++)
			add(sourceNodes[i])
		for (let i = 0; i < streamNodes.length; i++)
			add(streamNodes[i])
		for (let i = 0; i < captureNodes.length; i++)
			add(captureNodes[i])
		return list
	}

	PwObjectTracker {
		objects: root.tracked
	}

	Timer {
		interval: Config.audioPoll
		running: true
		onTriggered: {
			if (root.liveVolume >= 0) {
				root.volume = root.liveVolume
				root.muted = root.liveMuted
			}
			root.micVolume = root.sourceLevel
			root.micMuted = root.sourceMuted
			root.primed = true
		}
	}

	onLiveVolumeChanged: note()
	onLiveMutedChanged: note()
	onSourceLevelChanged: noteMic()
	onSourceMutedChanged: noteMic()

	function note() {
		if (!primed || liveVolume < 0)
			return
		const changed = Math.abs(liveVolume - volume) > Config.volumeEpsilon || liveMuted !== muted
		volume = liveVolume
		muted = liveMuted
		if (changed && !adjusting)
			NiriState.showOsd("volume")
		adjusting = false
	}

	function noteMic() {
		if (!primed || !source)
			return
		const changed = Math.abs(sourceLevel - micVolume) > Config.volumeEpsilon || sourceMuted !== micMuted
		micVolume = sourceLevel
		micMuted = sourceMuted
		if (changed && !micAdjusting)
			NiriState.showOsd("microphone")
		micAdjusting = false
	}

	Timer {
		interval: RadioState.menuPage === "audio" || RadioState.menuPage === "microphone" ? Config.audioListOpen : Config.audioListIdle
		repeat: true
		running: true
		triggeredOnStart: true
		onTriggered: root.collect()
	}

	function collect() {
		const model = Pipewire.nodes
		const list = model && model.values ? model.values : []
		const sinks = []
		const sources = []
		const streams = []
		const captures = []
		for (let i = 0; i < list.length; i++) {
			const node = list[i]
			if (!node || !node.audio)
				continue
			const type = node.type
			const stream = (type & PwNodeType.Stream) === PwNodeType.Stream
			const sinkBit = (type & PwNodeType.Sink) === PwNodeType.Sink
			const sourceBit = (type & PwNodeType.Source) === PwNodeType.Source
			if ((type & PwNodeType.Audio) !== PwNodeType.Audio)
				continue
			if (stream && sinkBit)
				streams.push(node)
			else if (!stream && sinkBit)
				sinks.push(node)
			if (stream && sourceBit && !isMonitor(node))
				captures.push(node)
			else if (!stream && sourceBit && !isMonitor(node))
				sources.push(node)
		}
		const sinkId = sink ? sink.id : -1
		sinks.sort((a, b) => {
			const da = a.id === sinkId
			const db = b.id === sinkId
			if (da !== db)
				return da ? -1 : 1
			return nodeLabel(a).localeCompare(nodeLabel(b))
		})
		const sourceId = source ? source.id : -1
		sources.sort((a, b) => {
			const da = a.id === sourceId
			const db = b.id === sourceId
			if (da !== db)
				return da ? -1 : 1
			return nodeLabel(a).localeCompare(nodeLabel(b))
		})
		streams.sort((a, b) => streamLabel(a).localeCompare(streamLabel(b)))
		captures.sort((a, b) => streamLabel(a).localeCompare(streamLabel(b)))
		const nextSinks = sinks.slice(0, Config.audioLimit)
		const nextSources = sources.slice(0, Config.audioLimit)
		const nextStreams = streams.slice(0, Config.audioLimit)
		const nextCaptures = captures.slice(0, Config.audioLimit)
		if (!sameNodes(sinkNodes, nextSinks))
			sinkNodes = nextSinks
		if (!sameNodes(sourceNodes, nextSources))
			sourceNodes = nextSources
		if (!sameNodes(streamNodes, nextStreams))
			streamNodes = nextStreams
		if (!sameNodes(captureNodes, nextCaptures))
			captureNodes = nextCaptures
	}

	function sameNodes(current, next) {
		if (current.length !== next.length)
			return false
		for (let i = 0; i < current.length; i++) {
			if (!current[i] || !next[i] || current[i].id !== next[i].id)
				return false
		}
		return true
	}

	function isMonitor(node) {
		const name = (node.name || "") + " " + (node.description || "")
		return name.indexOf(".monitor") !== -1 || name.indexOf("Monitor of") === 0
	}

	function nodeLabel(node) {
		if (!node)
			return ""
		return node.nickname || node.description || node.name || "Audio"
	}

	function streamLabel(node) {
		if (!node)
			return ""
		const props = node.properties || {}
		const app = props["application.name"] || node.description || node.name || "App"
		const media = props["media.name"] || ""
		if (media && media !== app)
			return app + " · " + media
		return app
	}

	function volumeGlyph(level, muted) {
		if (muted || level <= Config.muteFloor)
			return String.fromCodePoint(0xF075F)
		if (level < Config.volumeLow)
			return String.fromCodePoint(0xF057F)
		if (level < Config.volumeMid)
			return String.fromCodePoint(0xF0580)
		return String.fromCodePoint(0xF057E)
	}

	function micGlyph(muted) {
		return String.fromCodePoint(muted ? 0xF036D : 0xF036C)
	}

	function levelText(level, muted) {
		if (muted)
			return "Muted"
		return Math.round(Math.max(0, level) * 100) + "%"
	}

	function setVolume(node, value) {
		if (!node || !node.audio)
			return
		if (sink && node.id === sink.id)
			adjusting = true
		if (source && node.id === source.id)
			micAdjusting = true
		node.audio.volume = Math.max(0, Math.min(1, value))
	}

	function toggleMute(node) {
		if (!node || !node.audio)
			return
		node.audio.muted = !node.audio.muted
	}

	function selectSink(node) {
		if (node)
			Pipewire.preferredDefaultAudioSink = node
	}

	function selectSource(node) {
		if (node)
			Pipewire.preferredDefaultAudioSource = node
	}
}
