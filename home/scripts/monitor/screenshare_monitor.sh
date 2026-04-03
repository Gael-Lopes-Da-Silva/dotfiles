#!/usr/bin/env bash

while [[ -z $(pactl get-default-source) || $(pactl get-default-source) == "@DEFAULT_SOURCE@" ]]; do
    sleep 1
done

is_screensharing() {
    pw-dump | jq -e '
        .. | objects
        | select(.props?["media.class"] == "Video/Source")
        | select(
            .props?["node.name"]? // "" | test("portal|screen|capture"; "i")
            or
            .props?["application.name"]? // "" | test("portal|screen|capture"; "i")
        )
    ' >/dev/null
}

was_active=0

pw-mon | while read -r line; do
    if echo "$line" | grep -qiE 'Video/Source|portal|screen|capture'; then
        if is_screensharing; then
            if [ "$was_active" -eq 0 ]; then
                notify-send \
                    -a "osd" \
                    -h string:x-dunst-stack-tag:screenshare \
                    -t 3000 \
                    "Screenshare" "On"
                was_active=1
            fi
        else
            if [ "$was_active" -eq 1 ]; then
                notify-send \
                    -a "osd" \
                    -h string:x-dunst-stack-tag:screenshare \
                    -t 3000 \
                    "Screenshare" "Off"
                was_active=0
            fi
        fi
    fi
done
