#!/usr/bin/env bash

niri msg event-stream | while read -r line; do
    case "$line" in
        Workspace\ focused:*)
            workspace=${line#Workspace focused: }

            notify-send \
                -a "workspace" \
                -h string:x-dunst-stack-tag:workspace \
                -t 3000 \
                "Workspace" "$workspace"
            ;;
    esac
done
