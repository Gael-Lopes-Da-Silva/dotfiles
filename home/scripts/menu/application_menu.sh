#!/usr/bin/env bash

# Navigation:
#   ↑/↓            Move selection
#   Tab            Autocomplete query with selection
#   Enter          Launch selected application
#
# Behavior:
#   - Lists applications from .desktop files
#   - Displays application name (with optional description preview)
#   - Executes the associated command in background (detached)
#
# Notes:
#   - Sources:
#       /run/current-system/sw/share/applications
#       /etc/profiles/per-user/$USER/share/applications
#       ~/.local/share/applications
#   - Hidden apps (NoDisplay=true) are ignored
#   - Exec placeholders (e.g. %f, %u) are stripped
#   - Preview window shows application description when available

if pgrep -f "$TERMINAL.*--class custom:applications" >/dev/null; then
    exit 1
fi

$TERMINAL --class custom:applications -e bash -c '
    execute_item() {
        key="$1"
        value="$2"
        name="$3"

        case "$key" in
            __item__)
                [ -n "$value" ] && setsid gtk-launch "$value" >/dev/null 2>&1 &
                notify-send \
                    -a "clipboard" \
                    -t 5000 \
                    "Application launcher" "$name launched"
                ;;
        esac
    }; export -f execute_item

    generate_list() {
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
                    esac

                    if [ -n "$name" ] && [ -n "$nodisplay" ] && [ -n "$comment" ]; then
                        break
                    fi
                done < "$file"

                if [ -n "$name" ] && [ "$nodisplay" != "true" ]; then
                    app_map["$name"]="$(basename $file)"
                    app_desc_map["$name"]="$comment"
                fi
            done
        done

        for name in "${!app_map[@]}"; do
            printf "%s\t%s\t%s\t%s\n" "__item__" "$name" "${app_map[$name]}" "${app_desc_map[$name]}"
        done | sort
    }; export -f generate_list

    generate_list | fzf \
        --prompt=": " \
        --delimiter=$'\''\t'\'' \
        --with-nth=2 \
        --layout=reverse \
        --preview '\''echo {4}'\'' \
        --preview-window=down:10%,wrap \
        --bind '\''ctrl-c:'\'' \
        --bind '\''tab:replace-query'\'' \
        --bind '\''enter:execute(execute_item {1} {3} {2})+abort'\''
'

exit 0
