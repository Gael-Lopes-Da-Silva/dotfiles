#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class custom:applications" >/dev/null; then
    exit 0
fi

tmpfile=$(mktemp)

$TERMINAL --class custom:applications -e bash -c '
    desktop_dirs=(
        "/run/current-system/sw/share/applications"
        "/etc/profiles/per-user/$USER/share/applications"
        "$HOME/.local/share/applications"
    )

    declare -A app_map
    declare -A app_desc_map

    for dir in "${desktop_dirs[@]}"; do
        [ -d "$dir" ] || continue
        for file in "$dir"/*.desktop; do
            [ -f "$file" ] || continue

            name=""
            nodisplay=""
            exec_cmd=""
            comment=""

            while IFS="=" read -r key value; do
                case $key in
                    Name)
                        [ -z "$name" ] && name=$value
                        ;;
                    Comment)
                        [ -z "$comment" ] && comment=$value
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

                if [ -n "$name" ] && [ -n "$exec_cmd" ] && [ -n "$nodisplay" ] && [ -n "$comment" ]; then
                    break
                fi
            done < "$file"

            if [ -n "$name" ] && [ "$nodisplay" != "true" ] && [ -n "$exec_cmd" ]; then
                app_map["$name"]="$exec_cmd"
                app_desc_map["$name"]="$comment"
            fi
        done
    done

    selection=$(
        {
            for name in "${!app_map[@]}"; do
                printf "%s\t%s\t%s\n" "__item__" "$name" "${app_desc_map[$name]}"
            done | sort
        } | fzf \
            --prompt="Run: " \
            --delimiter=$'\''\t'\'' \
            --with-nth=2 \
            --layout=reverse \
            --bind "tab:replace-query" \
            --preview '\''echo {3}'\'' \
            --preview-window=down:10%,wrap
    )

    key=$(printf "%s" "$selection" | cut -d$'\''\t'\'' -f1)
    value=$(printf "%s" "$selection" | cut -d$'\''\t'\'' -f2)

    case "$key" in
        __item__)
            [ -n "$value" ] && printf "%s\n" "${app_map[$value]}" > "'$tmpfile'"
            ;;
    esac
'

fzf_output=$(cat "$tmpfile")
rm "$tmpfile"

cmd_to_run=$fzf_output
if [ -n "$cmd_to_run" ]; then
    nohup bash -c "$cmd_to_run" >/dev/null 2>&1 &
fi

exit 0
