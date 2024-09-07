#!/bin/sh

ICON=""
DATE=$(date +"%d/%m/%Y")
BIRTHDAY="19/06"

[[ $DATE = "" ]] && exit 1

[[ $(date +"%d/%m") = $BIRTHDAY ]] && ICON=""

echo " $ICON $DATE "
echo " $ICON $DATE "

[[ $(date +"%d/%m") = $BIRTHDAY ]] && echo "#e00a97"

exit 0
