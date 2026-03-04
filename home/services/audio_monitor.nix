{ config, pkgs, ... }:

{
  systemd.user.services = {
    audio_monitor = {
      Unit = {
        Description = "Audio OSD";
        After = [ "niri.service" ];
      };

      Service = {
        ExecStart = "${pkgs.bash}/bin/bash %h/.local/bin/audio_monitor.sh";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
