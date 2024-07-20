#!/bin/bash

SEPARATOR_WIDTH=10

current_time() {
    local TIME=$(date +"%T")
    local ICON="󰥔"

    echo "{"
    echo "'full_text': ' $ICON $TIME ',"
    echo "'name': 'id_time',"
    echo "'separator_block_width': $SEPARATOR_WIDTH,"
    echo "},"
}

current_date() {
    local DATE=$(date +"%d/%m/%Y")
    local ICON=""

    echo "{"
    echo "'full_text': ' $ICON $DATE ',"
    echo "'name': 'id_date',"
    echo "'separator_block_width': $SEPARATOR_WIDTH,"
    echo "},"
}

current_battery() {
    if [ -d /sys/class/power_supply/BAT1 ]; then
        local STATUS=$(cat /sys/class/power_supply/BAT1/status)
        local BATTERY=$(cat /sys/class/power_supply/BAT1/capacity)
        local BACKGROUND=""
        local ICON=""

        if [[ $STATUS = "Discharging" ]]; then
            [[ $BATTERY -le 15 ]] && BACKGROUND="#FF0000" || BACKGROUND=""
        fi

        if [[ $STATUS = "Charging" ]]; then
            [[ $BATTERY -ge 95 ]] && BACKGROUND="#00FF00" || BACKGROUND=""
        fi

        [[ $STATUS = "Charging" ]] && ICON="󱐋" || ICON="󰁹"

        echo "{"
        echo "'full_text': ' $ICON $BATTERY% ',"
        echo "'name': 'id_battery',"
        echo "'background': '$BACKGROUND',"
        echo "'separator_block_width': $SEPARATOR_WIDTH,"
        echo "},"
    fi
}

current_brightness() {
    if [ -d /sys/class/backlight/intel_backlight ]; then
        local ACTUAL_BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/actual_brightness)
        local MAX_BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/max_brightness)
        local BRIGHTNESS=$(( (100 * $ACTUAL_BRIGHTNESS) / $MAX_BRIGHTNESS ))
        local ICON="󰃠"

        echo "{"
        echo "'full_text': ' $ICON $BRIGHTNESS% ',"
        echo "'name': 'id_brightness',"
        echo "'separator_block_width': $SEPARATOR_WIDTH,"
        echo "},"
    fi
}

current_volume() {
    local VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
    local MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $3}')
    local BACKGROUND=""
    local ICON=""

    [[ $VOLUME > 0.00 ]] && ICON="󰕾" || ICON="󰖁"

    if [[ $MUTED = "[MUTED]" ]]; then
        VOLUME="MUTED"
        BACKGROUND="#b9b9b9"
        ICON="󰖁"
    fi

    echo "{"
    echo "'full_text': ' $ICON $VOLUME ',"
    echo "'name': 'id_volume',"
    echo "'background': '$BACKGROUND',"
    echo "'separator_block_width': $SEPARATOR_WIDTH,"
    echo "},"
}

current_mic() {
    local MIC=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $2}')
    local MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $3}')
    local BACKGROUND=""
    local ICON=""

    [[ $MIC > 0.00 ]] && ICON="" || ICON=""

    if [[ $MUTED = "[MUTED]" ]]; then
        MIC="MUTED"
        BACKGROUND="#b9b9b9"
        ICON=""
    fi

    echo "{"
    echo "'full_text': ' $ICON $MIC ',"
    echo "'name': 'id_mic',"
    echo "'background': '$BACKGROUND',"
    echo "'separator_block_width': $SEPARATOR_WIDTH,"
    echo "},"
}

echo "{'version': 1, 'click_events': true}"
echo "["
(while [ true ]; do
    echo -n "["
    current_mic
    current_volume
    current_brightness
    current_battery
    current_date
    current_time
    echo "],"

    sleep 1
done) &

while read line; do
    echo $line > /tmp/tmp.txt

    case $line in
        *"event"*"272"*) case $line in
            *"name"*"id_volume"*) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle & ;;
            *"name"*"id_mic"*) wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle & ;;
        esac;;
    esac
done
