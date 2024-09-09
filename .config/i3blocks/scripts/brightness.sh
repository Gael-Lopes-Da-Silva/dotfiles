#!/bin/sh

[ "$(brightnessctl -m | grep backlight)" = "" ] && exit 1

BRIGHTNESS=$(brightnessctl -m | awk '{split($1, array, ","); print array[4]}'); [ ! $? = 0 ] && exit 1
FOREGROUND="#FFFFFF"
ICON="󰃠"

echo " $ICON $BRIGHTNESS "
echo " $ICON $BRIGHTNESS "

echo $FOREGROUND

exit 0
