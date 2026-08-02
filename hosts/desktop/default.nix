{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "windows11";

  services.llama-cpp = {
    enable = true;
    package = pkgs.llama-cpp-vulkan;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}
