#!/bin/sh

ICON=
MIC=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $2}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $3}')
BACKGROUND=""

[[ $MIC = "" ]] && exit 1

[[ $button -eq 1 ]] && wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
[[ $button -eq 4 ]] && wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 10%+
[[ $button -eq 5 ]] && wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 10%-

[[ ! $MIC > 0.00 ]] && ICON=""

if [[ $MUTED = "[MUTED]" ]]; then
    MIC="MUTED"
    BACKGROUND="#b9b9b9"
    ICON=""
fi

echo " $ICON $MIC "
echo " $ICON $MIC "

if [[ ! $BACKGROUND = "" ]]; then
    echo "#FFFFFF"
    echo "$BACKGROUND"
fi

exit 0
