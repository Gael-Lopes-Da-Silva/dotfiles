#!/usr/bin/env bash

# Navigation:
#   ↑/↓            Move selection
#   Tab            Autocomplete query with selection
#   Enter          Execute selected action
#
# Available options:
#   Shutdown       Power off the system
#   Reboot         Restart the system
#   Suspend        Suspend to RAM
#   Hibernate      Suspend to disk
#   Logout         End current session
#   Lock           Lock current session
#
# Notes:
#   - Uses systemctl and loginctl for system/session control
#   - Requires appropriate permissions for power actions

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
                    niri msg action screenshot --path '' --show-pointer false
                " >/dev/null 2>&1 &
                ;;
            __wscrsht__)
                setsid nohup bash -c "
                    niri msg action screenshot-window --path '' --id \$(niri msg --json pick-window | jq -r '.id')
                " >/dev/null 2>&1 &
                ;;
            __fscrsht__)
                setsid nohup bash -c "
                    niri msg action screenshot --show-pointer false
                " >/dev/null 2>&1 &
                ;;
            __fwscrsht__)
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
            "__scrsht__" "Screenshot" \
            "__wscrsht__" "Screenshot window" \
            "__fscrsht__" "Screenshot to file" \
            "__fwscrsht__" "Screenshot window to file"
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
