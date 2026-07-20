{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "windows11";

  services = {
    ollama = {
      enable = true;
      package = pkgs.ollama-vulkan;
    };
  };

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
