{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "windows11";

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="event[0-9]*", \
      ATTRS{name}=="Sony Interactive Entertainment Wireless Controller Touchpad", \
      ENV{LIBINPUT_IGNORE_DEVICE}="1"

    ACTION=="add|change", KERNEL=="event[0-9]*", \
      ATTRS{name}=="Wireless Controller Touchpad", \
      ENV{LIBINPUT_IGNORE_DEVICE}="1"

    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_interface", \
      ATTRS{idVendor}=="054c", \
      ATTRS{idProduct}=="05c4|09cc", \
      DRIVER=="snd-usb-audio", \
      RUN+="/bin/sh -c 'echo %k > /sys/bus/usb/drivers/snd-usb-audio/unbind'"
  '';

  nix.settings = {
    substituters = [
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  home-manager.users.gael = {
    home.packages = with pkgs; [
      (blender.override {
        config.cudaSupport = true;
        config.rocmSupport = false;
      })
    ];

    wayland.windowManager = {
      niri.settings = {
        debug = {
          disable-cursor-plane = { };
        };

        _children = [
          {
            output = {
              _args = [ "HDMI-A-2" ];
              mode = "1920x1080@60";
              scale = 1.0;
              position._props = {
                x = 0;
                y = 0;
              };
            };
          }
          {
            output = {
              _args = [ "HDMI-A-1" ];
              mode = "1920x1080@100";
              scale = 1.0;
              position._props = {
                x = 0;
                y = 1080;
              };
            };
          }
        ];
      };
    };
  };
}
