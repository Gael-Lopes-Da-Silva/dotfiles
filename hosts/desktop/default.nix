{ ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "windows11";

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  home-manager.users.gael = {
    home.file.".config/niri/host.kdl".source = ./niri/host.kdl;
  };
}
