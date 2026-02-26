#!/usr/bin/env bash

if pgrep -f "alacritty.*--class soundboard" >/dev/null; then
    exit 0
fi

tmpfile=$(mktemp)

alacritty --class soundboard --command bash -c '
    find "$HOME/Music/Soundboard" -maxdepth 1 -type f \( \
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
    | fzf --prompt="Select: " --with-nth=1 --delimiter="\t" --bind "tab:replace-query" \
    | awk -F"\t" '\''{print $2}'\'' > "'$tmpfile'"
'

fzf_output=$(cat "$tmpfile")
rm "$tmpfile"

if [ -n "$fzf_output" ]; then
    paplay -d "SoundboardInput" $fzf_output &
    paplay -d "$(pactl get-default-sink)" $fzf_output &
fi

exit 0
