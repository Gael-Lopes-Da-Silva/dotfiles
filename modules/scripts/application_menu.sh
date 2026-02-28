#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class launcher" >/dev/null; then
    exit 0
fi

tmpfile=$(mktemp)

$TERMINAL --class launcher -e bash -c '
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

            name=
            nodisplay=
            exec_cmd=

            while IFS='=' read -r key value; do
                case $key in
                    Name)
                        [ -z "$name" ] && name=$value
                        ;;
                    NoDisplay)
                        nodisplay=$value
                        ;;
                    Exec)
                        if [ -z "$exec_cmd" ]; then
                            exec_cmd=$value
                            exec_cmd=${exec_cmd//%[a-zA-Z]/}
                        fi
                        ;;
                esac

                if [ -n "$name" ] && [ -n "$exec_cmd" ] && [ -n "$nodisplay" ]; then
                    break
                fi
            done < "$file"

            if [ -n "$name" ] && [ "$nodisplay" != "true" ] && [ -n "$exec_cmd" ]; then
                app_map["$name"]="$exec_cmd"
            fi
        done
    done

    selection=$(printf "%s\n" "${!app_map[@]}" | sort | fzf --prompt="Run Application: ")

    [ -n "$selection" ] && printf "%s\n" "${app_map[$selection]}" > "'$tmpfile'"
'

fzf_output=$(cat "$tmpfile")
rm "$tmpfile"

cmd_to_run=$fzf_output
if [ -n "$cmd_to_run" ]; then
    nohup bash -c "$cmd_to_run" >/dev/null 2>&1 &
fi

exit 0
