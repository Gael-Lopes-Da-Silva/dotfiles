{ ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "windows11";

  services.tlp.enable = true;
  services.auto-cpufreq.enable = true;
}
