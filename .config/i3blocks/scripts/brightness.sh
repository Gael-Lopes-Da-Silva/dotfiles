#!/bin/sh

[ $(xbacklight -list | grep backlight) = "" ] && exit 1

BRIGHTNESS="$(xbacklight -get)%"
FOREGROUND="#FFFFFF"
ICON="󰃠"

[ $BRIGHTNESS = "" ] && exit 1

echo " $ICON $BRIGHTNESS "
echo " $ICON $BRIGHTNESS "

echo $FOREGROUND

exit 0
