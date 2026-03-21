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
                [ -n "$value" ] && case "$value" in
                    Shutdown) systemctl poweroff ;;
                    Reboot) systemctl reboot ;;
                    Suspend) systemctl suspend ;;
                    Hibernate) systemctl hibernate ;;
                    Logout) loginctl terminate-session "$XDG_SESSION_ID" ;;
                    Lock) loginctl lock-session ;;
                esac
                ;;
        esac
    }; export -f execute_item

    generate_list() {
        printf "__item__\t%s\n" \
            "Shutdown" \
            "Reboot" \
            "Suspend" \
            "Hibernate" \
            "Logout" \
            "Lock"
    }; export -f generate_list

    generate_list | fzf \
        --prompt=": " \
        --layout=reverse \
        --delimiter=$'\''\t'\'' \
        --with-nth=2 \
        --bind '\''ctrl-c:'\'' \
        --bind '\''tab:replace-query'\'' \
        --bind '\''enter:execute-silent(bash -c "execute_item \"$@\"" _ {1} {2})+abort'\''
'

exit 0
