#!/bin/bash

while [[ -z $(pactl get-default-source) || -z $(pactl get-default-sink) ]]; do
    sleep 1
done

SINK_NAME=SoundboardInput
SOURCE_NAME=SoundboardOutput
MIC_SOURCE=$(pactl get-default-source)

if [[ $MIC_SOURCE != $SOURCE_NAME ]]; then
    pactl unload-module module-null-sink 2> /dev/null

    pactl load-module module-null-sink media.class=Audio/Sink sink_name=$SINK_NAME device.description=$SINK_NAME channel_map=stereo >> /dev/null
    pactl load-module module-null-sink media.class=Audio/Source/Virtual sink_name=$SOURCE_NAME device.description=$SOURCE_NAME channel_map=front-left,front-right >> /dev/null

    pw-link $MIC_SOURCE:capture_FL  $SINK_NAME:playback_FL 2> /dev/null
    pw-link $MIC_SOURCE:capture_FR  $SINK_NAME:playback_FR 2> /dev/null
    pw-link $MIC_SOURCE:capture_MONO  $SINK_NAME:playback_FL 2> /dev/null
    pw-link $MIC_SOURCE:capture_MONO  $SINK_NAME:playback_FR 2> /dev/null

    pw-link $SINK_NAME:monitor_FL $SOURCE_NAME:input_FL 2> /dev/null
    pw-link $SINK_NAME:monitor_FR $SOURCE_NAME:input_FR 2> /dev/null

    pactl set-default-source $SOURCE_NAME
fi
