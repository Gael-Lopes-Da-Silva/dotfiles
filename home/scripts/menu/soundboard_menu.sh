#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class custom:soundboard" >/dev/null; then
    exit 1
fi

$TERMINAL --class custom:soundboard -e bash -c '
    execute_item() {
        key="$1"
        value="$2"

        case "$key" in
            __stop__)
                pkill paplay
                dunstify \
                    -a "soundboard" \
                    -u normal \
                    -t 5000 \
                    "Soundboard" "All sounds have been stopped."
                exit 0
                ;;
            __delete__)
                if [ "$value" = "" ] || [ ! -f "$value" ]; then
                    exit 1
                fi

                confirm=$(printf "No\nYes" | fzf --prompt="Delete $(basename "$value")? ")

                [ "$confirm" != "Yes" ] && exit 0

                rm "$value"

                dunstify \
                    -a "soundboard" \
                    -u normal \
                    -t 5000 \
                    "Soundboard" "Deleted $(basename "$value") successfully."
                exit 0
                ;;
            __rstart__)
                record_file="$HOME/.soundboard/custom/record.mp3"

                trap '\'''\'' INT

                pw-record "$record_file" &
                pid=$!

                printf "Recording... Press ESC to stop.\r"

                while true; do
                    read -rsn1 key
                    if [[ $key == $'\''\e'\'' ]]; then
                        if kill -0 "$pid" 2>/dev/null; then  # check if process exists
                            kill "$pid"
                            wait "$pid" 2>/dev/null
                        fi
                        break
                    fi
                done

                dunstify \
                    -a "soundboard" \
                    -u normal \
                    -t 5000 \
                    "Soundboard" "Custom record successfully recorded."
                exit 0
                ;;
            __rplay__)
                setsid bash -c "
                    paplay --device=\"SoundboardSink\" --volume=65536 \"$HOME/.soundboard/custom/record.mp3\" &
                    paplay --device=\"\$(pactl get-default-sink)\" --volume=32768 \"$HOME/.soundboard/custom/record.mp3\" &
                " >/dev/null 2>&1 &
                exit 0
                ;;
            __rsave__)
                record_file="$HOME/.soundboard/custom/record.mp3"

                if [ ! -f "$record_file" ]; then
                    dunstify \
                        -a \"soundboard\" \
                        -u normal \
                        -t 5000 \
                        "Soundboard" "No recording found to save."
                    exit 1
                fi

                name=$(printf "" | fzf --print-query --prompt="Save as: ")

                [ -z "$name" ] && exit 1

                safe_name=$(echo "$name" | tr '\'' '\'' '\''-'\'' | tr -cd '\''[:alnum:]_-'\'' )

                dest="$HOME/.soundboard/${safe_name}.mp3"

                if [ -f "$dest" ]; then
                    dunstify \
                        -a "soundboard" \
                        -u normal \
                        -t 5000 \
                        "Soundboard" "File ${safe_name}.mp3 already exists."
                    exit 1
                fi

                cp "$record_file" "$dest"

                dunstify \
                    -a "soundboard" \
                    -u normal \
                    -t 5000 \
                    "Soundboard" "File ${safe_name}.mp3 saved successfully."
                exit 0
                ;;
            __item__)
                setsid bash -c "
                    paplay --device=\"SoundboardSink\" --volume=65536 \"$value\" &
                    paplay --device=\"\$(pactl get-default-sink)\" --volume=32768 \"$value\" &
                " >/dev/null 2>&1 &
                exit 0
                ;;
        esac
    }; export -f execute_item

    generate_list() {
        printf "__stop__\t📢 Stop\n"
        printf "__rplay__\t🔔 Play record\n"
        find "$HOME/.soundboard" -maxdepth 1 -type f \( \
            -iname "*.mp3" -o -iname "*.aac" -o -iname "*.wav" -o -iname "*.flac" \
            -o -iname "*.ogg" -o -iname "*.opus" -o -iname "*.aiff" \
            -o -iname "*.au" -o -iname "*.caf" -o -iname "*.raw" \
        \) | sort | awk -F/ '\''{
            name = $NF;
            sub(/\.[^.]*$/, "", name);
            gsub(/[-_]/, " ", name);
            name = toupper(substr(name,1,1)) substr(name,2);
            printf "__item__\t%s\t%s\n", name, $0
        }'\''
    }; export -f generate_list

    generate_list | fzf \
      --prompt=": " \
      --delimiter=$'\''\t'\'' \
      --with-nth=2 \
      --layout=reverse \
      --bind "tab:replace-query" \
      --preview '\''echo {3}'\'' \
      --preview-window=down:10%,wrap \
      --bind '\''ctrl-r:execute(bash -c "execute_item __rstart__ \"$@\"")'\'' \
      --bind '\''ctrl-s:execute(bash -c "execute_item __rsave__ \"$@\"")+reload(bash -c generate_list)'\'' \
      --bind '\''ctrl-d:execute(bash -c "execute_item __delete__ \"$@\"" _ {3})+reload(bash -c generate_list)'\'' \
      --bind '\''enter:execute-silent(bash -c "execute_item \"$@\"" _ {1} {3})'\''
'

exit 0
