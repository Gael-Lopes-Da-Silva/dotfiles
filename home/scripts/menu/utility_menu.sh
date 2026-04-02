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
#   Screenshot                 Capture screen (clipboard)
#   Screenshot window          Capture selected window (clipboard)
#   Screenshot to file         Capture screen (saved to file)
#   Screenshot window to file  Capture selected window (saved to file)
#
# Notes:
#   - Relies on external scripts in ~/.local/bin:
#       freeze_process.sh, mute_process.sh, kill_process.sh, pick_color.sh
#   - Uses niri for screenshot functionality
#   - Prevents multiple instances using terminal class detection

if pgrep -f "$TERMINAL.*--class custom:utility" >/dev/null; then
    exit 1
fi

run() {
    execute_item() {
        key="$1"
        value="$2"

        case "$key" in
            __freeze__)
                setsid nohup bash -c "
                    bash ~/.local/bin/freeze_process.sh -p
                " >/dev/null 2>&1 &
                ;;
            __mute__)
                setsid nohup bash -c "
                    bash ~/.local/bin/mute_process.sh -p
                " >/dev/null 2>&1 &
                ;;
            __kill__)
                setsid nohup bash -c "
                    bash ~/.local/bin/kill_process.sh -p
                " >/dev/null 2>&1 &
                ;;
            __color__)
                setsid nohup bash -c "
                    bash ~/.local/bin/pick_color.sh
                " >/dev/null 2>&1 &
                ;;
            __scrsht__)
                setsid nohup bash -c "
                    niri msg action screenshot-window --path '' --id \$(niri msg --json pick-window | jq -r '.id')
                " >/dev/null 2>&1 &
                ;;
            __fscrsht__)
                setsid nohup bash -c "
                    niri msg action screenshot-window --id \$(niri msg --json pick-window | jq -r '.id')
                " >/dev/null 2>&1 &
                ;;
        esac
    }; export -f execute_item

    generate_list() {
        printf "%s\t%s\n" \
            "__freeze__" "Pick freeze" \
            "__mute__" "Pick mute" \
            "__kill__" "Pick kill" \
            "__color__" "Pick color" \
            "__scrsht__" "Screenshot window" \
            "__fscrsht__" "Screenshot window to file"
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
