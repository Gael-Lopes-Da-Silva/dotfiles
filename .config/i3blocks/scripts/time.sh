#!/bin/sh

TIME=$(date +"%T"); [ ! $? = 0 ] && exit 1
FOREGROUND="#FFFFFF"
ICON="󰥔"

[ $(date +"%H") -eq 12 || $(date +"%H") -eq 19 ] && ICON="󰩰"
[ $(date +"%H") -ge 00 && $(date +"%H") -le 07 ] && ICON="󰖔"

echo " $ICON $TIME "
echo " $ICON $TIME "

echo $FOREGROUND

exit 0
