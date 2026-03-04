#!/usr/bin/env bash

SOUNDBOARD_SINK="SoundboardInput"
SOUNDBOARD_SOURCE="SoundboardOutput"

REAL_MIC=$(wpctl get-default-source | awk '{print $2}')

pw-link "$REAL_MIC:capture_FL" "$SOUNDBOARD_SINK:playback_FL" 2>/dev/null
pw-link "$REAL_MIC:capture_FR" "$SOUNDBOARD_SINK:playback_FR" 2>/dev/null
pw-link "$REAL_MIC:capture_MONO" "$SOUNDBOARD_SINK:playback_FL" 2>/dev/null
pw-link "$REAL_MIC:capture_MONO" "$SOUNDBOARD_SINK:playback_FR" 2>/dev/null

pw-link "$SOUNDBOARD_SINK:monitor_FL" "$SOUNDBOARD_SOURCE:input_FL" 2>/dev/null
pw-link "$SOUNDBOARD_SINK:monitor_FR" "$SOUNDBOARD_SOURCE:input_FR" 2>/dev/null

wpctl set-default "$SOUNDBOARD_SOURCE"

mkdir -p "$HOME/.soundboard"

exit 0
