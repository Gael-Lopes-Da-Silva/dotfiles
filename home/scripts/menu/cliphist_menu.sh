#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class custom:cliphist" >/dev/null; then
    exit 0
fi

tmpfile=$(mktemp)

$TERMINAL --class custom:cliphist -e bash -c '
    selection=$(
        {
            printf "__clear__\t🧹 Clear\n"
            cliphist list \
            | sort -t $'\''\t'\'' -k1,1nr \
            | while IFS=$'\''\t'\'' read -r id text; do
                printf "__item__\t%s\t%s\n" "$text" "$id"
            done
        } | fzf \
            --no-sort \
            --prompt="Copy: " \
            --delimiter=$'\''\t'\'' \
            --with-nth=2 \
            --layout=reverse
    )

    key=$(printf "%s" "$selection" | cut -d$'\''\t'\'' -f1)
    value=$(printf "%s" "$selection" | cut -d$'\''\t'\'' -f3)

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
            [ -n "$value" ] && printf "%s" "$value" > "'$tmpfile'"
            ;;
    esac
'

fzf_output=$(cat "$tmpfile")
rm "$tmpfile"

item_to_copy=$fzf_output
if [ -n "$item_to_copy" ]; then
    printf "%s" $item_to_copy | cliphist decode | wl-copy
fi

exit 0
