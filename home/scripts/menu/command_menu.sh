#!/usr/bin/env bash

# Navigation:
#   ↑/↓            Move selection
#   Tab            Autocomplete query with selection
#   Enter          Execute selected command
#
# Actions:
#   Ctrl-F         Browse the man page of the selected command
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

run() {
    execute_item() {
        key="$1"
        value="$2"

        case "$key" in
            __info__)
                if [ -n "$value" ] && man -w "$value" >/dev/null 2>&1; then
                    bash -c "man '$value'"
                    clear
                fi
                ;;
            __item__)
                if [[ -n "$value" ]]; then
                    setsid nohup bash -c "
                        bash -c '$value'
                    " >/dev/null 2>&1 &
                fi
                ;;
        esac
    }; export -f execute_item

    generate_list() {
        compgen -c | sort -u | while IFS=$'\n' read -r command; do
            printf "__item__\t%s\n" "$command"
        done
    }; export -f generate_list

    generate_list | fzf \
        --prompt=": " \
        --delimiter=$'\t' \
        --with-nth=2 \
        --layout=reverse \
        --bind 'ctrl-c:' \
        --bind 'tab:replace-query' \
        --bind 'ctrl-f:execute(execute_item __info__ {2})' \
        --bind 'enter:execute(execute_item {1} {2})+abort'
}; export -f run

$TERMINAL --class custom:commands -e bash -c run

exit 0
