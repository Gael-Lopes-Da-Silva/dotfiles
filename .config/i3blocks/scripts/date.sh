#!/bin/sh

DATE=$(date +"%d/%m/%Y")
BIRTHDAY="19/06"
FOREGROUND="#FFFFFF"
ICON=""

[ $DATE = "" ] && exit 1

[ $(date +"%d/%m") = $BIRTHDAY ] && ICON=""

echo " $ICON $DATE "
echo " $ICON $DATE "

echo $FOREGROUND

exit 0
