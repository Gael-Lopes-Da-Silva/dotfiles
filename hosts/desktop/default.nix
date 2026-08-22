{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "windows11";

  environment.systemPackages = with pkgs; [
    llama-cpp-vulkan
  ];

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
  '';
}
