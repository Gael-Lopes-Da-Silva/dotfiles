#!/bin/sh

ICON="󰕾"
VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $3}')
BACKGROUND=""

[[ $VOLUME = "" ]] && exit 1

[[ $button -eq 1 ]] && wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
[[ $button -eq 4 ]] && wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%+
[[ $button -eq 5 ]] && wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-

[[ ! $VOLUME > 0.00 ]] && ICON="󰖁"

if [[ $MUTED = "[MUTED]" ]]; then
    VOLUME="MUTED"
    BACKGROUND="#b9b9b9"
    ICON="󰖁"
fi

echo " $ICON $VOLUME "
echo " $ICON $VOLUME "

if [[ ! $BACKGROUND = "" ]]; then
    echo "#FFFFFF"
    echo "$BACKGROUND"
fi

exit 0
