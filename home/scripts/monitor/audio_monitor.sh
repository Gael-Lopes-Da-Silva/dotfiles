#!/usr/bin/env bash

while [[ -z $(pactl get-default-source) || $(pactl get-default-source) == "@DEFAULT_SOURCE@" ]]; do
    sleep 1
done

prev_sink_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -d '%')
prev_sink_mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
prev_source_volume=$(pactl get-source-volume @DEFAULT_SOURCE@ | awk '{print $5}' | tr -d '%')
prev_source_mute=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')

pactl subscribe | while read -r line; do
    case "$line" in
        *"on sink"*)
            sink_volume=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | tr -d '%')
            sink_mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

            if [ "$sink_mute" != "$prev_sink_mute" ]; then
                if [ "$sink_mute" = "yes" ]; then
                    notify-send \
                        -a "volume" \
                        -h string:x-dunst-stack-tag:volume \
                        -t 3000 \
                        "Speaker" "Muted"
                else
                    notify-send \
                        -a "volume" \
                        -h string:x-dunst-stack-tag:volume \
                        -t 3000 \
                        "Speaker" "Unmuted"
                fi

                prev_sink_mute="$sink_mute"
            elif [ "$sink_volume" -ne "$prev_sink_volume" ]; then
                notify-send \
                    -a "volume" \
                    -h string:x-dunst-stack-tag:volume \
                    -h int:value:$sink_volume \
                    -t 3000 \
                    "Speaker" "$sink_volume%"

                prev_sink_volume="$sink_volume"
            fi

            prev_sink_volume="$sink_volume"
            ;;

        *"on source"*)
            source_volume=$(pactl get-source-volume @DEFAULT_SOURCE@ | awk '{print $5}' | tr -d '%')
            source_mute=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')

            if [ "$source_mute" != "$prev_source_mute" ]; then
                if [ "$source_mute" = "yes" ]; then
                    notify-send \
                        -a "microphone" \
                        -h string:x-dunst-stack-tag:microphone \
                        -t 3000 \
                        "Microphone" "Muted"
                else
                    notify-send \
                        -a "microphone" \
                        -h string:x-dunst-stack-tag:microphone \
                        -t 3000 \
                        "Microphone" "Unmuted"
                fi

                prev_source_mute="$source_mute"
            elif [ "$source_volume" -ne "$prev_source_volume" ]; then
                notify-send \
                    -a "microphone" \
                    -h string:x-dunst-stack-tag:microphone \
                    -h int:value:$source_volume \
                    -t 3000 \
                    "Microphone" "$source_volume%"

                prev_source_volume="$source_volume"
            fi

            prev_source_volume="$source_volume"
            ;;
    esac
done
