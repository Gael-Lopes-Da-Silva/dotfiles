#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class custom:cliphist" >/dev/null; then
    exit 0
fi

$TERMINAL --class custom:cliphist -e bash -c '
    selection=$(
        {
            echo "__clear__:🧹 Clear"
            cliphist list | sed "s/^/__item__:/"
        } | fzf --no-sort --prompt="Copy: " --delimiter=":" --with-nth=2
    )

    key=$(printf "%s" "$selection" | cut -d":" -f1)
    value=$(printf "%s" "$selection" | cut -d":" -f2-)

    case "$key" in
        __clear__)
            cliphist wipe
            dunstify \
                -a "clipboard" \
                -u normal \
                -t 5000 \
                "Clipboard history" "The clipboard history was successfully cleared."
            ;;
        __item__)
            [ -n "$value" ] && printf "%s" "$value" | cliphist decode | wl-copy
            ;;
    esac
'

exit 0
