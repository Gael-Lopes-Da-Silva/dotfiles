#!/usr/bin/env bash

# Navigation:
#   ↑/↓            Move selection
#   Tab            Autocomplete query with selection
#   Enter          Play selected sound
#
# Actions:
#   Ctrl+F         Play last recorded sound
#   Ctrl+C         Stop all currently playing sounds
#   Ctrl+R         Start recording from microphone (ESC to stop)
#   Ctrl+S         Save last recording
#   Ctrl+D         Delete selected sound file
#
# Behavior:
#   - Plays selected sounds on both "SoundboardSink" and default output
#   - Recording is saved to ~/.soundboard/custom/record.mp3
#
# Notes:
#   - Supported formats: mp3, wav, flac, ogg, opus, etc.
#   - Files are stored in ~/.soundboard

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
                ;;
            __delete__)
                if [ "$value" = "" ] || [ ! -f "$value" ]; then
                    exit 1
                fi

                confirm=$(printf "No\nYes" | fzf --prompt="Delete $(basename "$value")? ")

                [ "$confirm" != "Yes" ] && exit 0

                rm "$value"

                notify-send \
                    -a "soundboard" \
                    -t 5000 \
                    "Soundboard" "Deleted $(basename "$value") successfully."
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
                        if kill -0 "$pid" 2>/dev/null; then
                            kill "$pid"
                            wait "$pid" 2>/dev/null
                        fi
                        break
                    fi
                done

                notify-send \
                    -a "soundboard" \
                    -t 5000 \
                    "Soundboard" "Custom record successfully recorded."
                ;;
            __rplay__)
                setsid bash -c "
                    paplay --device=\"SoundboardSink\" --volume=65536 \"$HOME/.soundboard/custom/record.mp3\" &
                    paplay --device=\"\$(pactl get-default-sink)\" --volume=32768 \"$HOME/.soundboard/custom/record.mp3\" &
                " >/dev/null 2>&1 &
                ;;
            __rsave__)
                record_file="$HOME/.soundboard/custom/record.mp3"

                if [ ! -f "$record_file" ]; then
                    notify-send \
                        -a \"soundboard\" \
                        -t 5000 \
                        "Soundboard" "No recording found to save."
                    exit 1
                fi

                name=$(printf "" | fzf --print-query --prompt="Save as: ")

                [ -z "$name" ] && exit 1

                safe_name=$(echo "$name" | tr '\'' '\'' '\''-'\'' | tr -cd '\''[:alnum:]_-'\'' )

                dest="$HOME/.soundboard/${safe_name}.mp3"

                if [ -f "$dest" ]; then
                    notify-send \
                        -a "soundboard" \
                        -t 5000 \
                        "Soundboard" "File ${safe_name}.mp3 already exists."
                    exit 1
                fi

                cp "$record_file" "$dest"

                notify-send \
                    -a "soundboard" \
                    -t 5000 \
                    "Soundboard" "File ${safe_name}.mp3 saved successfully."
                ;;
            __item__)
                setsid bash -c "
                    paplay --device=\"SoundboardSink\" --volume=65536 \"$value\" &
                    paplay --device=\"\$(pactl get-default-sink)\" --volume=32768 \"$value\" &
                " >/dev/null 2>&1 &
                ;;
        esac
    }; export -f execute_item

    generate_list() {
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
        --preview '\''echo {3}'\'' \
        --preview-window=down:10%,wrap \
        --bind '\''tab:replace-query'\'' \
        --bind '\''ctrl-f:execute-silent(execute_item __rplay__)'\'' \
        --bind '\''ctrl-c:execute-silent(execute_item __stop__)'\'' \
        --bind '\''ctrl-r:execute(execute_item __rstart__)'\'' \
        --bind '\''ctrl-s:execute(execute_item __rsave__)+reload(bash -c generate_list)'\'' \
        --bind '\''ctrl-d:execute(execute_item __delete__ {3})+reload(bash -c generate_list)'\'' \
        --bind '\''enter:execute-silent(execute_item {1} {3})'\''
'

exit 0
