STATUS=$(acpi -b | awk '{print $3}')
BATTERY=$(acpi -b | grep -E -o '[0-9][0-9]?%')
BACKGROUND=""
ICON=""


BAT=$(acpi -b | grep -E -o '[0-9][0-9]?%')

echo "Battery: $BAT"
echo "BAT: $BAT"

[ ${BAT%?} -le 53 ] && exit 33

# if [[ $BATTERY -eq "" ]]; then
#     exit 1
# fi
#
# if [[ $STATUS = "Discharging," ]]; then
#     [[ $BATTERY -le 15 ]] && BACKGROUND="#FF0000" || BACKGROUND=""
# fi
#
# if [[ $STATUS = "Charging," ]]; then
#     [[ $BATTERY -ge 95 ]] && BACKGROUND="#00FF00" || BACKGROUND=""
# fi
#
# [[ $STATUS = "Charging," ]] && ICON="󱐋" || ICON="󰁹"
#
# echo " $ICON $BATTERY "

exit 0
