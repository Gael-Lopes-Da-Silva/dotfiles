#!/bin/bash

VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'); [ ! $? = 0 ] && exit 0
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print length($3) != 0 ? 1 : 0}'); [ ! $? = 0 ] && exit 0
FOREROUND="#FFFFFF"
ICON="󰕾"

[ $VOLUME = "0.00" ] && ICON="󰖁"

if [ $MUTED = 1 ]; then
    VOLUME="MUTED"
    FOREROUND="#b9b9b9"
    ICON="󰖁"
fi

echo " $ICON $VOLUME "
echo " $ICON $VOLUME "

echo $FOREROUND

exit 0
