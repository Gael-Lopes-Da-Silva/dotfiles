let
  soundboardScript = pkgs.writeShellScriptBin "soundboard-setup" {
    name = "soundboard-setup";
    runtimeDependencies = [
      pkgs.pipewire
      pkgs.pipewireTools
      pkgs.gnugrep
      pkgs.coreutils
    ];
    text = ''
      SOUNDBOARD_SINK="SoundboardInput"
      SOUNDBOARD_SOURCE="SoundboardOutput"

      if pw-link --links | grep -Eq "$SOUNDBOARD_SINK|$SOUNDBOARD_SOURCE"; then
        echo "Soundboard links already exist, skipping."
        exit 0
      fi

      REAL_MIC=$(pactl get-default-source)

      pw-link "$REAL_MIC:capture_FL" "$SOUNDBOARD_SINK:playback_FL" 2>/dev/null
      pw-link "$REAL_MIC:capture_FR" "$SOUNDBOARD_SINK:playback_FR" 2>/dev/null
      pw-link "$REAL_MIC:capture_MONO" "$SOUNDBOARD_SINK:playback_FL" 2>/dev/null
      pw-link "$REAL_MIC:capture_MONO" "$SOUNDBOARD_SINK:playback_FR" 2>/dev/null

      pw-link "$SOUNDBOARD_SINK:monitor_FL" "$SOUNDBOARD_SOURCE:input_FL" 2>/dev/null
      pw-link "$SOUNDBOARD_SINK:monitor_FR" "$SOUNDBOARD_SOURCE:input_FR" 2>/dev/null

      pactl set-default-source "$SOUNDBOARD_SOURCE"

      mkdir -p "$HOME/.soundboard"

      exit 0
    '';
  };
in {
  systemd.user.services.soundboard = {
    Unit = {
      Description = "Soundboard Setup";
      After = [ "pipewire.service" "pipewire-pulse.service" ];
      BindsTo = "pipewire.service";
      PartOf = "pipewire.service";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${soundboardScript}";
      RemainAfterExit = true;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
