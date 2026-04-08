#!/usr/bin/env bash

# Navigation:
#   ↑/↓            Move selection
#   Enter          Copy selected entry to clipboard
#
# Actions:
#   Ctrl-D         Delete selected entry
#   Ctrl-Q         Delete entries matching a query
#   Ctrl-C         Clear entire clipboard history (irreversible)
#
# Behavior:
#   - Displays clipboard history (most recent first)
#   - Uses `fzf` for interactive filtering and selection
#   - Automatically reloads the list after modifications
#
# Notes:
#   - Requires: cliphist, wl-copy, fzf, notify-send
#   - Clipboard content is decoded before being copied
#   - Clearing history cannot be undone

if pgrep -f "$TERMINAL.*--class custom:cliphist" >/dev/null; then
    exit 1
fi

run() {
    execute_item() {
        key="$1"
        value="$2"

        case "$key" in
            __clear__)
                cliphist wipe

                notify-send \
                    -a "notification" \
                    -t 5000 \
                    "Clipboard history" "The clipboard history was successfully cleared."
                ;;
            __qdelete__)
                query=$(
                    yad --entry \
                        --text='Select a query to delete from.' \
                        --button='OK:0' \
                        --button='Cancel:1'
                )
                [[ -z "$query" ]] && exit 1

                {
                    yad --question \
                        --text='Do you really want to delete all those entries?' \
                        --button='OK:0' \
                        --button='Cancel:1'
                } || exit 0

                cliphist delete-query $query

                notify-send \
                    -a "notification" \
                    -t 5000 \
                    "Clipboard history" "Deleted all entries with '$query'."
                ;;
            __delete__)
                if [[ -n "$value" ]]; then
                    {
                        yad --question \
                            --text='Do you really want to delete this entry?' \
                            --button='OK:0' \
                            --button='Cancel:1'
                    } || exit 0

                    printf '%s' "$value" | cliphist delete

                    notify-send \
                        -a "notification" \
                        -t 5000 \
                        "Clipboard history" "Entry successfully deleted."
                fi
                ;;
            __item__)
                [[ -n "$value" ]] && setsid nohup bash -c "
                    printf '%s' '$value' | cliphist decode | wl-copy
                " >/dev/null 2>&1 &

                notify-send \
                    -a "notification" \
                    -t 5000 \
                    "Clipboard history" "You can paste the copy from the clipboard entry."
                ;;
        esac
    }; export -f execute_item

    generate_list() {
        cliphist list \
            | sort -t $'\t' -k1,1nr \
            | while IFS=$'\t' read -r id text; do
                printf "__item__\t%s\t%s\n" "$text" "$id"
            done
    }; export -f generate_list

    generate_list | fzf \
        --no-sort \
        --prompt=": " \
        --delimiter=$'\t' \
        --with-nth=2 \
        --layout=reverse \
        --bind 'ctrl-q:execute(execute_item __qdelete__)+reload(bash -c generate_list)' \
        --bind 'ctrl-d:execute(execute_item __delete__ {3})+reload(bash -c generate_list)' \
        --bind 'ctrl-c:execute-silent(execute_item __clear__)+reload(bash -c generate_list)' \
        --bind 'enter:execute(execute_item {1} {3})+abort'
}; export -f run

$TERMINAL --class custom:cliphist -e bash -c run

exit 0
