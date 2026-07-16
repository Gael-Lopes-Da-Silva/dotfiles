{ pkgs, ... }:

{
  home.file =
    pkgs.lib.mapAttrs'
      (filename: srcPath: {
        name = ".local/sounds/${filename}";
        value = {
          source = srcPath;
        };
      })
      {
        "windows-11-notify.mp3" = ./windows-11-notify.;
        "windows-11-startup.mp3" = ./windows-11-startup.mp3.;
        "windows-11-usb-disconnect.mp3" = ./windows-11-usb-disconnect.mp3.;
        "windows-11-usb-insert.mp3" = ./windows-11-usb-insert.mp3.;
      };
}
