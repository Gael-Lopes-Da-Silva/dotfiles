{ config, pkgs, ... }:

{
  systemd.user.services = {
    soundboard = {
      Unit = {
        Description = "Soundboard Setup";
        After = [ "pipewire.service" "pipewire-pulse.service" ];
        BindsTo = "pipewire.service";
        PartOf = "pipewire.service";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "%h/.local/bin/soundboard_setup.sh";
        RemainAfterExit = true;
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    audio_monitor = {
      Unit = {
        Description = "Audio OSD";
        After = [ "niri.service" ];
      };

      Service = {
        ExecStart = "%h/.local/bin/audio_monitor.sh";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    battery_monitor = {
      Unit = {
        Description = "Battery OSD";
        After = [ "niri.service" ];
      };

      Service = {
        ExecStart = "%h/.local/bin/battery_monitor.sh";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    brightness_monitor = {
      Unit = {
        Description = "Brightness OSD";
        After = [ "niri.service" ];
      };

      Service = {
        ExecStart = "%h/.local/bin/brightness_monitor.sh";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
