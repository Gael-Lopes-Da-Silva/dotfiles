{ config, pkgs, ... }:

let
  audioMonitorScript = pkgs.writeShellScript "volume-listener" ''
    #!${pkgs.bash}/bin/bash

    until pactl get-default-sink >/dev/null 2>&1; do
        sleep 0.5
    done

    until pactl get-default-source >/dev/null 2>&1; do
        sleep 0.5
    done

    prev_sink_volume=$(${pkgs.pulseaudio}/bin/pactl get-sink-volume @DEFAULT_SINK@ | ${pkgs.gawk}/bin/awk '{print $5}' | ${pkgs.coreutils}/bin/tr -d '%')
    prev_sink_mute=$(${pkgs.pulseaudio}/bin/pactl get-sink-mute @DEFAULT_SINK@ | ${pkgs.gawk}/bin/awk '{print $2}')
    prev_source_volume=$(${pkgs.pulseaudio}/bin/pactl get-source-volume @DEFAULT_SOURCE@ | ${pkgs.gawk}/bin/awk '{print $5}' | ${pkgs.coreutils}/bin/tr -d '%')
    prev_source_mute=$(${pkgs.pulseaudio}/bin/pactl get-source-mute @DEFAULT_SOURCE@ | ${pkgs.gawk}/bin/awk '{print $2}')

    ${pkgs.pulseaudio}/bin/pactl subscribe | while read -r line; do
        case "$line" in
            *"on sink"*)
                sink_volume=$(${pkgs.pulseaudio}/bin/pactl get-sink-volume @DEFAULT_SINK@ | ${pkgs.gawk}/bin/awk '{print $5}' | ${pkgs.coreutils}/bin/tr -d '%')
                sink_mute=$(${pkgs.pulseaudio}/bin/pactl get-sink-mute @DEFAULT_SINK@ | ${pkgs.gawk}/bin/awk '{print $2}')

                if [ "$sink_mute" != "$prev_sink_mute" ]; then
                    if [ "$sink_mute" = "yes" ]; then
                        ${pkgs.dunst}/bin/dunstify -a "volume" -h string:x-dunst-stack-tag:volume -u low -t 5000 "Speaker" "Muted"
                    else
                        ${pkgs.dunst}/bin/dunstify -a "volume" -h string:x-dunst-stack-tag:volume -u low -t 5000 "Speaker" "Unmuted"
                    fi
                    prev_sink_mute="$sink_mute"
                elif [ "$sink_volume" -ne "$prev_sink_volume" ]; then
                    ${pkgs.dunst}/bin/dunstify -a "volume" -h string:x-dunst-stack-tag:volume -h int:value:"$sink_volume" -u low -t 5000 "Speaker" "$sink_volume%"
                    prev_sink_volume="$sink_volume"
                fi
                ;;
            *"on source"*)
                source_volume=$(${pkgs.pulseaudio}/bin/pactl get-source-volume @DEFAULT_SOURCE@ | ${pkgs.gawk}/bin/awk '{print $5}' | ${pkgs.coreutils}/bin/tr -d '%')
                source_mute=$(${pkgs.pulseaudio}/bin/pactl get-source-mute @DEFAULT_SOURCE@ | ${pkgs.gawk}/bin/awk '{print $2}')

                if [ "$source_mute" != "$prev_source_mute" ]; then
                    if [ "$source_mute" = "yes" ]; then
                        ${pkgs.dunst}/bin/dunstify -a "microphone" -h string:x-dunst-stack-tag:microphone -u low -t 5000 "Microphone" "Muted"
                    else
                        ${pkgs.dunst}/bin/dunstify -a "microphone" -h string:x-dunst-stack-tag:microphone -u low -t 5000 "Microphone" "Unmuted"
                    fi
                    prev_source_mute="$source_mute"
                elif [ "$source_volume" -ne "$prev_source_volume" ]; then
                    ${pkgs.dunst}/bin/dunstify -a "microphone" -h string:x-dunst-stack-tag:microphone -h int:value:"$source_volume" -u low -t 5000 "Microphone" "$source_volume%"
                    prev_source_volume="$source_volume"
                fi
                ;;
        esac
    done
  '';
in
{
  systemd.user.services.volume-listener = {
    description = "Volume & Microphone Notification OSD";

    after = [
      "pipewire.service"
      "wireplumber.service"
      "dunst.service"
    ];

    wantedBy = [ "default.target" ];

    serviceConfig = {
      ExecStart = audioMonitorScript;
      Restart = "always";
      RestartSec = 1;
    };
  };
}
