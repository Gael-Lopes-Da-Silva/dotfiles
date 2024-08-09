#!/bin/bash

BATTERY=$(acpi -b | grep -E -o '[0-9][0-9]?[0-9]?%')
STATUS=$(acpi -b | awk '{print $3}')
BACKGROUND=""

[[ $BATTERY = "" ]] && exit 1

if [[ $STATUS = "Discharging," ]]; then
    [[ ${BATTERY%?} -le 15 ]] && BACKGROUND="#FF8000"
    [[ ${BATTERY%?} -le 5 ]] && BACKGROUND="#FF0000"
    ICON="󰁹"
fi

if [[ $STATUS = "Charging," ]]; then
    [[ ${BATTERY%?} -ge 95 ]] && BACKGROUND="#00FF00"
    ICON="󱐋"
fi

echo " $ICON $BATTERY "
echo " $ICON $BATTERY "

if [[ ! $BACKGROUND = "" ]]; then
    echo "#FFFFFF"
    echo "$BACKGROUND"
fi

exit 0
