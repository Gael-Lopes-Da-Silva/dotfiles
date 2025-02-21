#!/bin/bash

SINK_NAME=SoundboardInput
SOURCE_NAME=SoundboardOutput
MIC_SOURCE=$(pactl get-default-source)

pactl unload-module module-null-sink 2> /dev/null

pactl load-module module-null-sink media.class=Audio/Sink sink_name=$SINK_NAME device.description=$SINK_NAME channel_map=stereo >> /dev/null
pactl load-module module-null-sink media.class=Audio/Source/Virtual sink_name=$SOURCE_NAME device.description=$SOURCE_NAME channel_map=front-left,front-right >> /dev/null

pw-link $MIC_SOURCE:capture_FL  $SINK_NAME:playback_FL
pw-link $MIC_SOURCE:capture_FR  $SINK_NAME:playback_FR

pw-link $SINK_NAME:monitor_FL $SOURCE_NAME:input_FL
pw-link $SINK_NAME:monitor_FR $SOURCE_NAME:input_FR

pactl set-default-source $SOURCE_NAME
