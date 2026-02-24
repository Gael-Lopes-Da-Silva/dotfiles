#!/usr/bin/env bash

if pgrep -f "alacritty.*--class launcher" >/dev/null; then
    exit 0
fi

tmpfile=$(mktemp)

alacritty --class launcher --command bash -c '
    desktop_dirs=(
        /usr/share/applications
        /usr/local/share/applications
        "$HOME/.local/share/applications"
    )

    declare -A app_map

    for dir in "${desktop_dirs[@]}"; do
        [ -d "$dir" ] || continue

        for file in "$dir"/*.desktop; do
            [ -f "$file" ] || continue

            name=$(grep -m1 "^Name=" "$file" | cut -d= -f2-)
            nodisplay=$(grep -m1 "^NoDisplay=" "$file" | cut -d= -f2-)
            exec_cmd=$(grep -m1 "^Exec=" "$file" | cut -d= -f2- | sed "s/%[a-zA-Z]//g" | xargs)

            if [ -n "$name" ] && [ "$nodisplay" != "true" ] && [ -n "$exec_cmd" ]; then
                app_map["$name"]="$exec_cmd"
            fi
        done
    done

    selection=$(printf "%s\n" "${!app_map[@]}" | sort | fzf --prompt="Run: ")

    [ -n "$selection" ] && printf "%s\n" "${app_map[$selection]}" > "'$tmpfile'"
'

fzf_output=$(cat "$tmpfile")
rm "$tmpfile"

cmd_to_run=$fzf_output
if [ -n "$cmd_to_run" ]; then
    nohup bash -c "$cmd_to_run" >/dev/null 2>&1 &
fi

exit 0
