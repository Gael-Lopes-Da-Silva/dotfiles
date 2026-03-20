#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class custom:soundboard" >/dev/null; then
    exit 0
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
                ;;
            __rstart__)
                pw-record "$HOME/.soundboard/custom/record.mp3"
                dunstify \
                    -a "soundboard" \
                    -u normal \
                    -t 5000 \
                    "Soundboard" "Custom record successfully recorded."
                ;;
            __rplay__)
                setsid bash -c "
                    paplay --device=\"SoundboardSink\" --volume=65536 \"$HOME/.soundboard/custom/record.mp3\" &
                    paplay --device=\"\$(pactl get-default-sink)\" --volume=32768 \"$HOME/.soundboard/custom/record.mp3\" &
                " >/dev/null 2>&1 &
                ;;
            __item__)
                setsid bash -c "
                    paplay --device=\"SoundboardSink\" --volume=65536 \"$value\" &
                    paplay --device=\"\$(pactl get-default-sink)\" --volume=32768 \"$value\" &
                " >/dev/null 2>&1 &
                ;;
        esac
    }; export -f execute_item

    {
        printf "__stop__\t📢 Stop\n"
        printf "__rstart__\t📲 Record start\n"
        printf "__rplay__\t📱 Record play\n"
        find "$HOME/.soundboard" -maxdepth 1 -type f \( \
            -iname "*.mp3" -o -iname "*.aac" -o -iname "*.wav" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.opus" -o -iname "*.aiff" -o -iname "*.au" -o -iname "*.caf" -o -iname "*.raw" \
        \) \
        | sort \
        | awk -F/ '\''{
            name = $NF;
            sub(/\.[^.]*$/, "", name);
            gsub(/[-_]/, " ", name);
            name = toupper(substr(name,1,1)) substr(name,2);
            printf "__item__\t%s\t%s\n", name, $0
        }'\''
    } | fzf \
      --prompt=": " \
      --delimiter=$'\''\t'\'' \
      --with-nth=2 \
      --layout=reverse \
      --bind "tab:replace-query" \
      --preview '\''echo {3}'\'' \
      --preview-window=down:10%,wrap \
      --bind '\''enter:execute(bash -c "execute_item \"$@\"" _ {1} {3})'\''
'

exit 0
