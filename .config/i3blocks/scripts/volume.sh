#!/bin/bash

VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $3}')
BACKGROUND=""

if [[ $button -eq 1 ]]; then
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
fi

if [[ $button -eq 4 ]]; then
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+
fi

if [[ $button -eq 5 ]]; then
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-
fi

[[ $VOLUME > 0.00 ]] && ICON="󰕾" || ICON="󰖁"

if [[ $MUTED = "[MUTED]" ]]; then
    VOLUME="MUTED"
    BACKGROUND="#b9b9b9"
    ICON="󰖁"
fi

echo " $ICON $VOLUME "
echo " $ICON $VOLUME "

if [[ ! $BACKGROUND -eq "" ]]; then
    echo "#FFFFFF"
    echo "$BACKGROUND"
fi

exit 0
