#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class custom:commands" >/dev/null; then
    exit 0
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

    {
        compgen -c | sort -u | while IFS=$'\''\n'\'' read -r command; do
            printf "__item__\t%s\n" "$command"
        done
    } | fzf \
        --prompt=": " \
        --delimiter=$'\''\t'\'' \
        --with-nth=2 \
        --bind "tab:replace-query" \
        --bind '\''enter:execute-silent(bash -c "execute_item \"$@\"" _ {1} {2})+abort'\''
'

exit 0
