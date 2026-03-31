#!/usr/bin/env bash

# Navigation:
#   ↑/↓            Move selection
#   Enter          Copy selected entry to clipboard
#
# Behavior:
#   - Displays clipboard history entries (most recent first)
#   - Selecting an entry copies it back to the clipboard
#
# Notes:
#   - Uses `cliphist` for history management
#   - Uses `wl-copy` for clipboard access (Wayland)
#   - Clearing history is irreversible

if pgrep -f "$TERMINAL.*--class custom:cliphist" >/dev/null; then
    exit 1
fi

$TERMINAL --class custom:cliphist -e bash -c '
    execute_item() {
        key="$1"
        value="$2"

        case "$key" in
            __clear__)
                cliphist wipe
                notify-send \
                    -a "clipboard" \
                    -t 5000 \
                    "Clipboard history" "The clipboard history was successfully cleared."
                ;;
            __qdelete__)
                query=$(printf "" | fzf --print-query --prompt="Query to delete: ")
                [ -z "$query" ] && exit 1

                confirm=$(printf "No\nYes" | fzf --prompt="Delete those entries? ")
                [ "$confirm" != "Yes" ] && exit 0

                cliphist delete-query $query
                ;;
            __delete__)
                confirm=$(printf "No\nYes" | fzf --prompt="Delete this entry? ")
                [ "$confirm" != "Yes" ] && exit 0

                [ -n "$value" ] && printf "%s" $value | cliphist delete
                ;;
            __item__)
                [ -n "$value" ] && setsid bash -c "printf \"%s\" $value | cliphist decode | wl-copy" >/dev/null 2>&1 &
                ;;
        esac
    }; export -f execute_item

    generate_list() {
        cliphist list \
            | sort -t $'\''\t'\'' -k1,1nr \
            | while IFS=$'\''\t'\'' read -r id text; do
                printf "__item__\t%s\t%s\n" "$text" "$id"
            done
    }; export -f generate_list

    generate_list | fzf \
        --no-sort \
        --prompt=": " \
        --delimiter=$'\''\t'\'' \
        --with-nth=2 \
        --layout=reverse \
        --bind '\''ctrl-q:execute(execute_item __qdelete__)+reload(bash -c generate_list)'\'' \
        --bind '\''ctrl-d:execute(execute_item __delete__ {3})+reload(bash -c generate_list)'\'' \
        --bind '\''ctrl-c:execute-silent(execute_item __clear__)+reload(bash -c generate_list)'\'' \
        --bind '\''enter:execute(execute_item {1} {3})+abort'\''
'

exit 0
