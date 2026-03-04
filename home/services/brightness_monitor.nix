{ config, pkgs, ... }:

{
  systemd.user.services = {
    brightness_monitor = {
      Unit = {
        Description = "Brightness OSD";
        After = [ "niri.service" ];
      };

      Service = {
        ExecStart = "${pkgs.bash}/bin/bash %h/.local/bin/brightness_monitor.sh";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
