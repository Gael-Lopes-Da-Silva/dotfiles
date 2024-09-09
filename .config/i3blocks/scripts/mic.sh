#!/bin/sh

MIC=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $2}'); [ ! $? = 0 ] && exit 1
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print length($3) != 0 ? 1 : 0}'); [ ! $? = 0 ] && exit 1
FOREROUND="#FFFFFF"
ICON=""

[ $MIC = "0.00" ] && ICON=""

if [ $MUTED = 1 ]; then
    MIC="MUTED"
    FOREROUND="#b9b9b9"
    ICON=""
fi

echo " $ICON $MIC "
echo " $ICON $MIC "

echo $FOREROUND

exit 0
