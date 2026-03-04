{ config, pkgs, ... }:

let
  soundboardScript = pkgs.writeShellScript "soundboard-init" ''
    #!${pkgs.bash}/bin/bash

    SOUNDBOARD_SINK="SoundboardInput"
    SOUNDBOARD_SOURCE="SoundboardOutput"

    if ${pkgs.pipewire}/bin/pw-link --links | grep -Eq "$SOUNDBOARD_SINK|$SOUNDBOARD_SOURCE"; then
        echo "Soundboard links already exist, skipping."
        exit 0
    fi

    REAL_MIC=$(${pkgs.pulseaudio}/bin/pactl get-default-source)

    ${pkgs.pipewire}/bin/pw-link "$REAL_MIC:capture_FL" "$SOUNDBOARD_SINK:playback_FL" 2>/dev/null
    ${pkgs.pipewire}/bin/pw-link "$REAL_MIC:capture_FR" "$SOUNDBOARD_SINK:playback_FR" 2>/dev/null
    ${pkgs.pipewire}/bin/pw-link "$REAL_MIC:capture_MONO" "$SOUNDBOARD_SINK:playback_FL" 2>/dev/null
    ${pkgs.pipewire}/bin/pw-link "$REAL_MIC:capture_MONO" "$SOUNDBOARD_SINK:playback_FR" 2>/dev/null

    ${pkgs.pipewire}/bin/pw-link "$SOUNDBOARD_SINK:monitor_FL" "$SOUNDBOARD_SOURCE:input_FL" 2>/dev/null
    ${pkgs.pipewire}/bin/pw-link "$SOUNDBOARD_SINK:monitor_FR" "$SOUNDBOARD_SOURCE:input_FR" 2>/dev/null

    ${pkgs.pulseaudio}/bin/pactl set-default-source "$SOUNDBOARD_SOURCE"

    mkdir -p "$HOME/.soundboard"

    exit 0
  '';
in
{
  systemd.user.services.soundboard = {
    description = "Soundboard Setup";

    after = [ "pipewire.service" "wireplumber.service" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = soundboardScript;
    };
  };
}
