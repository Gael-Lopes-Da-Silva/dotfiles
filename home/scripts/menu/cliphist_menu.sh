#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class custom:cliphist" >/dev/null; then
    exit 1
fi

$TERMINAL --class custom:cliphist -e bash -c '
    execute_item() {
        key="$1"
        value="$2"

        case "$key" in
            __clear__)
                cliphist wipe
                dunstify \
                    -a "clipboard" \
                    -u normal \
                    -t 5000 \
                    "Clipboard history" "The clipboard history was successfully cleared."
                ;;
            __item__)
                [ -n "$value" ] && setsid bash -c "printf \"%s\" $value | cliphist decode | wl-copy" >/dev/null 2>&1 &
                ;;
        esac
    }; export -f execute_item

    generate_list() {
        cliphist list \
            | sort -t $'\''\t'\'' -k1,1nr \
            | while IFS=$'\''\t'\'' read -r id text; do
                printf "__item__\t%s\t%s\n" "$text" "$id"
            done
    }; export -f generate_list

    generate_list | fzf \
        --no-sort \
        --prompt=": " \
        --delimiter=$'\''\t'\'' \
        --with-nth=2 \
        --layout=reverse \
        --bind '\''ctrl-c:execute-silent(bash -c "execute_item __clear__ \"$@\"")+reload(bash -c generate_list)'\'' \
        --bind '\''enter:execute-silent(bash -c "execute_item \"$@\"" _ {1} {3})+abort'\''
'

exit 0
