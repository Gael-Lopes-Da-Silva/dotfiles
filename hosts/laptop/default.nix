{ ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "windows11";

  services.tlp.enable = true;
  services.auto-cpufreq.enable = true;

  home-manager.users.gael = {
    home.file.".config/niri/host.kdl".source = ./niri/host.kdl;
  };
}
