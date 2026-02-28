{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      fzf
    ];

    home.file.".local/bin/application_menu.sh".source = ./application_menu.sh;
    home.file.".local/bin/audio_monitor.sh".source = ./audio_monitor.sh;
    home.file.".local/bin/battery_monitor.sh".source = ./battery_monitor.sh;
    home.file.".local/bin/battery_notify.sh".source = ./battery_notify.sh;
    home.file.".local/bin/brightness_monitor.sh".source = ./brightness_monitor.sh;
    home.file.".local/bin/cliphist_menu.sh".source = ./cliphist_menu.sh;
    home.file.".local/bin/command_menu.sh".source = ./command_menu.sh;
    home.file.".local/bin/keys_monitor.sh".source = ./keys_monitor.sh;
    home.file.".local/bin/power_menu.sh".source = ./power_menu.sh;
    home.file.".local/bin/soundboard_menu.sh".source = ./soundboard_menu.sh;
    home.file.".local/bin/soundboard_setup.sh".source = ./soundboard_setup.sh;
  };
}
