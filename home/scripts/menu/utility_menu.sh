#!/usr/bin/env bash

# Navigation:
#   ↑/↓            Move selection
#   Tab            Autocomplete query with selection label
#   Enter          Execute selected action
#
# Available actions:
#   Pick freeze                Select and freeze a process
#   Pick mute                  Select and mute a process
#   Pick kill                  Select and kill a process
#   Pick color                 Open color picker
#   Screenshot window          Capture selected window (clipboard)
#   Screenshot window to file  Capture selected window (saved to file)
#
# Notes:
#   - Relies on external scripts in ~/.local/bin:
#       freeze_process.sh, mute_process.sh, kill_process.sh, pick_color.sh
#   - Uses niri for screenshot functionality

if pgrep -f "$TERMINAL.*--class custom:utility" >/dev/null; then
    exit 1
fi

run() {
    execute_item() {
        key="$1"

        case "$key" in
            __freeze__)
                setsid nohup bash ~/.local/bin/freeze_process.sh -p &
                ;;
            __mute__)
                setsid nohup bash ~/.local/bin/mute_process.sh -p &
                ;;
            __kill__)
                setsid nohup bash ~/.local/bin/kill_process.sh -p &
                ;;
            __color__)
                setsid nohup bash ~/.local/bin/pick_color.sh &
                ;;
        esac
    }; export -f execute_item

    generate_list() {
        printf "%s\t%s\n" \
            "__freeze__" "Pick freeze" \
            "__mute__" "Pick mute" \
            "__kill__" "Pick kill" \
            "__color__" "Pick color"
    }; export -f generate_list

    generate_list | fzf \
        --prompt=": " \
        --layout=reverse \
        --delimiter=$'\t' \
        --with-nth=2 \
        --bind 'ctrl-c:' \
        --bind 'tab:replace-query' \
        --bind 'enter:execute(execute_item {1})+abort'
}; export -f run

$TERMINAL --class custom:utility -e bash -c run

exit 0
