#!/usr/bin/env bash

# Navigation:
#   ↑/↓            Move selection
#   Tab            Autocomplete query with selection
#   Enter          Execute selected command
#
# Behavior:
#   - Lists all available shell commands (from $PATH and builtins)
#   - Executes selected command in background (detached)
#
# Notes:
#   - Uses `compgen -c` to gather commands
#   - Output is silenced (stdout/stderr redirected to /dev/null)
#   - Useful as a quick command palette / launcher

if pgrep -f "$TERMINAL.*--class custom:commands" >/dev/null; then
    exit 1
fi

$TERMINAL --class custom:commands -e bash -c '
    execute_item() {
        key="$1"
        value="$2"

        case "$key" in
            __item__)
                [ -n "$value" ] && setsid bash -c "$value" >/dev/null 2>&1 &
                ;;
        esac
    }; export -f execute_item

    generate_list() {
        compgen -c | sort -u | while IFS=$'\''\n'\'' read -r command; do
            printf "__item__\t%s\n" "$command"
        done
    }; export -f generate_list

    generate_list | fzf \
        --prompt=": " \
        --delimiter=$'\''\t'\'' \
        --with-nth=2 \
        --layout=reverse \
        --bind '\''ctrl-c:'\'' \
        --bind '\''tab:replace-query'\'' \
        --bind '\''enter:execute(execute_item {1} {2})+abort'\''
'

exit 0
