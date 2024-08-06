STATUS=$(acpi -b | awk '{print $3}')
BATTERY=$(acpi -b | grep -E -o '[0-9][0-9]?%')
BACKGROUND=""
ICON=""

if [[ $BATTERY -eq "" ]]; then
    exit 1
fi

if [[ $STATUS = "Discharging," ]]; then
    [ ${BATTERY%?} -le 5 ] && BACKGROUND="#FF0000"
    [ ${BATTERY%?} -le 15 ] && BACKGROUND="#FF8000"
fi

if [[ $STATUS = "Charging," ]]; then
    [ ${BATTERY%?} -ge 95 ] && BACKGROUND="#00FF00"
fi

[[ $STATUS = "Charging," ]] && ICON="󱐋" || ICON="󰁹"

echo " $ICON $BATTERY " # full text
echo ""                 # short text

if [[ ! $BACKGROUND -eq "" ]]; then
    echo "#FFFFFF"
    echo "$BACKGROUND"
fi

exit 0
