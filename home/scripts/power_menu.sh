#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class powermenu" >/dev/null; then
    exit 0
fi

tmpfile=$(mktemp)

$TERMINAL --class powermenu -e bash -c '
    options=(
        "Shutdown"
        "Reboot"
        "Suspend"
        "Hibernate"
        "Logout"
        "Lock"
    )

    printf "%s\n" "${options[@]}" | fzf --prompt="Select: " --bind "tab:replace-query" > "'$tmpfile'"
'

fzf_output=$(cat "$tmpfile")
rm "$tmpfile"

case "$fzf_output" in
    Shutdown) systemctl poweroff ;;
    Reboot) systemctl reboot ;;
    Suspend) systemctl suspend ;;
    Hibernate) systemctl hibernate ;;
    Logout) loginctl terminate-session "$XDG_SESSION_ID" ;;
    Lock) loginctl lock-session ;;
esac

exit 0
