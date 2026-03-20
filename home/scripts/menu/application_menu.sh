#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class custom:applications" >/dev/null; then
    exit 0
fi

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

    execute_item() {
        key="$1"
        value="$2"

        case "$key" in
            __item__)
                [ -n "$value" ] && setsid bash -c "$value" >/dev/null 2>&1 &
                ;;
        esac
    }; export -f execute_item

    {
        for name in "${!app_map[@]}"; do
            printf "%s\t%s\t%s\t%s\n" "__item__" "$name" "${app_map[$name]}" "${app_desc_map[$name]}"
        done | sort
    } | fzf \
        --prompt="Run: " \
        --delimiter=$'\''\t'\'' \
        --with-nth=2 \
        --layout=reverse \
        --bind "tab:replace-query" \
        --preview '\''echo {4}'\'' \
        --preview-window=down:10%,wrap \
        --bind '\''enter:execute-silent(bash -c "execute_item \"$@\"" _ {1} {3})+abort'\''
'

exit 0
