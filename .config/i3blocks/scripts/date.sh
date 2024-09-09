#!/bin/sh

DATE=$(date +"%d/%m/%Y"); [ ! $? = 0 ] && exit 1
BIRTHDAY="19/06"
FOREGROUND="#FFFFFF"
ICON=""

[ $(date +"%d/%m") = $BIRTHDAY ] && ICON=""

echo " $ICON $DATE "
echo " $ICON $DATE "

echo $FOREGROUND

exit 0
