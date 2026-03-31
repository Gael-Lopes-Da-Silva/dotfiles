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

if pgrep -f "$TERMINAL.*--class custom:powermenu" >/dev/null; then
    exit 1
fi

$TERMINAL --class custom:powermenu -e bash -c '
    execute_item() {
        key="$1"
        value="$2"

        case "$key" in
            __item__)
                confirm=$(printf "No\nYes" | fzf --prompt="Confirm choice? ")
                [ "$confirm" != "Yes" ] && exit 0

                [ -n "$value" ] && bash -c "$value"
                ;;
        esac
    }; export -f execute_item

    generate_list() {
        printf "__item__\t%s\t%s\n" \
            "Shutdown" "systemctl poweroff" \
            "Reboot" "systemctl reboot" \
            "Suspend" "systemctl suspend" \
            "Hibernate" "systemctl hibernate" \
            "Logout" "loginctl terminate-user $USER" \
            "Lock" "loginctl lock-session"
    }; export -f generate_list

    generate_list | fzf \
        --prompt=": " \
        --layout=reverse \
        --delimiter=$'\''\t'\'' \
        --with-nth=2 \
        --preview '\''echo {3}'\'' \
        --preview-window=down:10%,wrap \
        --bind '\''ctrl-c:'\'' \
        --bind '\''tab:replace-query'\'' \
        --bind '\''enter:execute(execute_item {1} {3})+abort'\''
'

exit 0
