#!/bin/bash

MIC=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $2}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $3}')
BACKGROUND=""

if [[ $button -eq 1 ]]; then
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
fi

if [[ $button -eq 4 ]]; then
    wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 10%+
fi

if [[ $button -eq 5 ]]; then
    wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 10%-
fi

[[ $MIC > 0.00 ]] && ICON="" || ICON=""

if [[ $MUTED = "[MUTED]" ]]; then
    MIC="MUTED"
    BACKGROUND="#b9b9b9"
    ICON=""
fi

echo " $ICON $MIC "
echo " $ICON $MIC "

if [[ ! $BACKGROUND -eq "" ]]; then
    echo "#FFFFFF"
    echo "$BACKGROUND"
fi

exit 0
