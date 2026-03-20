#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class custom:powermenu" >/dev/null; then
    exit 0
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

    {
        printf "__item__\t%s\n" \
            "Shutdown" \
            "Reboot" \
            "Suspend" \
            "Hibernate" \
            "Logout" \
            "Lock"
    } | fzf \
        --prompt=": " \
        --layout=reverse \
        --delimiter=$'\''\t'\'' \
        --with-nth=2 \
        --bind "tab:replace-query" \
        --bind '\''enter:execute-silent(bash -c "execute_item \"$@\"" _ {1} {2})+abort'\''
'

exit 0
