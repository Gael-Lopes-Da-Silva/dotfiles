#!/usr/bin/env bash

while [[ -z $(pactl get-default-source) || $(pactl get-default-source) == "@DEFAULT_SOURCE@" ]]; do
    sleep 1
done

SOUNDBOARD_SINK="SoundboardSink"
SOUNDBOARD_SOURCE="SoundboardSource"

if pw-link --links | grep -Eq "$SOUNDBOARD_SINK|$SOUNDBOARD_SOURCE"; then
    echo "Soundboard links already exist, skipping."
    exit 1
fi

REAL_MIC=$(pactl get-default-source)

pw-link "$REAL_MIC:capture_FL" "$SOUNDBOARD_SINK:playback_FL" 2>/dev/null
pw-link "$REAL_MIC:capture_FR" "$SOUNDBOARD_SINK:playback_FR" 2>/dev/null
pw-link "$REAL_MIC:capture_MONO" "$SOUNDBOARD_SINK:playback_FL" 2>/dev/null
pw-link "$REAL_MIC:capture_MONO" "$SOUNDBOARD_SINK:playback_FR" 2>/dev/null

pw-link "$SOUNDBOARD_SINK:monitor_FL" "$SOUNDBOARD_SOURCE:input_FL" 2>/dev/null
pw-link "$SOUNDBOARD_SINK:monitor_FR" "$SOUNDBOARD_SOURCE:input_FR" 2>/dev/null

mkdir -p $HOME/.soundboard
mkdir -p $HOME/.soundboard/custom

exit 0
