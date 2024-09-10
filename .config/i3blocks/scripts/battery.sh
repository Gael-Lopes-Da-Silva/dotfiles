#!/bin/sh

# upower -i $(upower -e | grep /battery) | grep --color=never -E "state|percentage"
BATTERY=$(acpi | grep --color=never -E -o "[0-9]?[0-9]?[0-9]?%") || exit; [ $? -ne 0 ] && exit 1
STATUS=$(acpi | awk '{split($3, array, ","); print tolower(array[1])}') || exit; [ $? -ne 0 ] && exit 1
FOREGROUND="#FFFFFF"
ICON="󰁹"

[ $STATUS = "discharging" ] && ICON="󰁹"
[ $STATUS = "charging" ] && ICON="󱐋"
[ $STATUS = "full" ] && ICON=""

if [ $STATUS = "discharging" ]; then
    [ $BATTERY -le 15 ] && FOREGROUND="#FF8000"
    [ $BATTERY -le 5 ] && FOREGROUND="#FF0000"
fi

if [ $STATUS = "discharging" ]; then
    [ $BATTERY -ge 95 ] && FOREGROUND="#00FF00"
fi

[ $STATUS = "full" ] && FOREGROUND="#0000FF"

echo " $ICON $BATTERY "
echo " $ICON $BATTERY "

echo $FOREGROUND

exit 0
