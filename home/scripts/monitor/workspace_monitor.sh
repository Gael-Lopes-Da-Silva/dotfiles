#!/usr/bin/env bash

niri msg event-stream | while read -r line; do
    case "$line" in
        Workspace\ focused:*)
            workspace=$(niri msg workspaces | awk '/\*/ {print $2}')

            notify-send \
                -a "workspace" \
                -h string:x-dunst-stack-tag:workspace \
                -t 3000 \
                "Workspace" "$workspace"
            ;;
    esac
done
