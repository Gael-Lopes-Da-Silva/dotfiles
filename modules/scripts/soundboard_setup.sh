#!/usr/bin/env bash

while [[ -z $(pactl get-default-source) || $(pactl get-default-source) == "@DEFAULT_SOURCE@" ]]; do
    sleep 1
done

SOUNDBOARD_SINK="SoundboardInput"
SOUNDBOARD_SOURCE="SoundboardOutput"

pactl unload-module $(pactl list short modules | grep null-sink | grep $SOUNDBOARD_SINK | cut -f1) 2>/dev/null
pactl unload-module $(pactl list short modules | grep null-sink | grep $SOUNDBOARD_SOURCE | cut -f1) 2>/dev/null
for id in $(pactl list short modules | awk -v name="$SOUNDBOARD_SINK" '$0 ~ name {print $1}'); do
    pactl unload-module "$id"
done

pw-cli destroy $(pw-cli list-objects Link | grep -B 5 -A 5 -E "$DEFAULT_MIC|$SOUNDBOARD_SINK|$SOUNDBOARD_SOURCE" | grep 'id ' | awk '{print $2}') 2>/dev/null

SOUNDBOARD_MIC=$(pactl get-default-source | sed "s/\.monitor$//")

pactl load-module module-null-sink media.class=Audio/Sink sink_name=$SOUNDBOARD_SINK device.description=$SOUNDBOARD_SINK channel_map=stereo >/dev/null
pactl load-module module-null-sink media.class=Audio/Source/Virtual sink_name=$SOUNDBOARD_SOURCE device.description=$SOUNDBOARD_SOURCE channel_map=front-left,front-right >/dev/null

pw-link $SOUNDBOARD_MIC:capture_FL $SOUNDBOARD_SINK:playback_FL 2>/dev/null
pw-link $SOUNDBOARD_MIC:capture_FR $SOUNDBOARD_SINK:playback_FR 2>/dev/null
pw-link $SOUNDBOARD_MIC:capture_MONO $SOUNDBOARD_SINK:playback_FL 2>/dev/null
pw-link $SOUNDBOARD_MIC:capture_MONO $SOUNDBOARD_SINK:playback_FR 2>/dev/null
pw-link $SOUNDBOARD_SINK:monitor_FL $SOUNDBOARD_SOURCE:input_FL 2>/dev/null
pw-link $SOUNDBOARD_SINK:monitor_FR $SOUNDBOARD_SOURCE:input_FR 2>/dev/null

pactl set-default-source $SOUNDBOARD_SOURCE

mkdir -p $HOME/.oundboard

exit 0
