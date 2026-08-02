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
}
