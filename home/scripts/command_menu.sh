#!/usr/bin/env bash

if pgrep -f "alacritty.*--class launcher" >/dev/null; then
    exit 0
fi

tmpfile=$(mktemp)

$TERMINAL --class launcher -e bash -c '
    compgen -c | sort -u | fzf --prompt="Run Command: " --bind "tab:replace-query" --print-query > "'$tmpfile'"
'

fzf_output=$(cat "$tmpfile")
rm "$tmpfile"

query=$(head -n1 <<< "$fzf_output")
selection=$(sed -n '2p' <<< "$fzf_output")

cmd_to_run="${selection:-$query}"

if [ -n "$cmd_to_run" ]; then
    if [[ "$cmd_to_run" == *"!" ]]; then
        $TERMINAL -e bash -c "${cmd_to_run%?}" &
    else
        nohup bash -c "$cmd_to_run" >/dev/null 2>&1 &
    fi
fi

exit 0
