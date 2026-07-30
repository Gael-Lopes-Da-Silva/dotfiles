{ ... }:

{
  imports = [
    ./hardware.nix
    ./security.nix
  ];

  services = {
    tlp.enable = true;
    auto-cpufreq.enable = true;
  };
}
