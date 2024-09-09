#!/bin/sh

[ "$(xbacklight -list | grep backlight)" = "" ] && exit 1

BRIGHTNESS=$(xbacklight -get); [ ! $? = 0 ] && exit 1
FOREGROUND="#FFFFFF"
ICON="󰃠"

echo " $ICON $BRIGHTNESS% "
echo " $ICON $BRIGHTNESS% "

echo $FOREGROUND

exit 0
