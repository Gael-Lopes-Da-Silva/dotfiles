#!/usr/bin/env bash

if pgrep -f "$TERMINAL.*--class custom:soundboard" >/dev/null; then
    exit 0
fi

tmpfile=$(mktemp)

$TERMINAL --class custom:soundboard -e bash -c '
    selection=$(
        {
            echo "__stop__:📢 Stop"
            find "$HOME/.soundboard" -maxdepth 1 -type f \( \
                -iname "*.mp3" -o -iname "*.aac" -o -iname "*.wav" -o -iname "*.flac" -o -iname "*.ogg" -o -iname "*.opus" -o -iname "*.aiff" -o -iname "*.au" -o -iname "*.caf" -o -iname "*.raw" \
            \) \
            | sort \
            | awk -F/ '\''{
                name = $NF;
                sub(/\.[^.]*$/, "", name);
                gsub(/[-_]/, " ", name);
                name = toupper(substr(name,1,1)) substr(name,2);
                print name "\t" $0
            }'\'' \
            | sed "s/^/__item__:/"
        } | fzf --prompt="Play: " --delimiter=":" --with-nth=2 --bind "tab:replace-query"
    )

    key=$(printf "%s" "$selection" | cut -d":" -f1)
    value=$(printf "%s" "$selection" | cut -d":" -f2-)

    case "$key" in
        __stop__)
            pkill paplay
            dunstify \
                -a "soundboard" \
                -h string:x-dunst-stack-tag:soundboard \
                -u normal \
                -t 5000 \
                "Soundboard" "All sounds have been stopped."
            ;;
        __item__)
            [ -n "$value" ] && printf "%s" "$value" | awk -F"\t" '\''{print $2}'\'' > "'$tmpfile'"
            ;;
    esac
'

fzf_output=$(cat "$tmpfile")
rm "$tmpfile"

if [ -n "$fzf_output" ]; then
    paplay --device="SoundboardSpeaker" --volume=65536 $fzf_output &
    paplay --device="$(pactl get-default-sink)" --volume=32768 $fzf_output &
fi

exit 0
