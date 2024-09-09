#!/bin/sh

TIME=$(date +"%T")
FOREGROUND="#FFFFFF"
ICON="󰥔"

[ $TIME == "" ] && exit 1

[ $(date +"%H") -eq 12 || $(date +"%H") -eq 19 ] && ICON="󰩰"
[ $(date +"%H") -ge 00 && $(date +"%H") -le 07 ] && ICON="󰖔"

echo " $ICON $TIME "
echo " $ICON $TIME "

echo $FOREGROUND

exit 0
