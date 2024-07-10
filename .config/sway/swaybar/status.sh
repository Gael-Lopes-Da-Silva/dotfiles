#!/bin/bash

current_date() {
    DATE=$(date +' %x | 󰥔 %X')

    echo "$DATE"
}

current_battery() {
    if [ -d /sys/class/power_supply/BAT1 ]; then
        STATUS=$(cat /sys/class/power_supply/BAT1/status)
        BATTERY=$(cat /sys/class/power_supply/BAT1/capacity)

        [[ $STATUS = "Charging" ]] && STATUS="󱐋" || STATUS="󰁹"

        echo "$STATUS $BATTERY% | "
    fi
}

current_brightness() {
    if [ -d /sys/class/backlight/intel_backlight ]; then
        ACTUAL_BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/actual_brightness)
        MAX_BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/max_brightness)
        BRIGHTNESS=$(( (100 * $ACTUAL_BRIGHTNESS) / $MAX_BRIGHTNESS ))

        echo "󰖨 $BRIGHTNESS% | "
    fi
}

while [ true ]; do
    echo "| $(current_brightness)$(current_battery)$(current_date) |"
    sleep 1
done
