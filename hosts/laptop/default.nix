{ ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "windows11";

  services = {
    tlp.enable = true;
    auto-cpufreq.enable = true;
    ollama.enable = true;
  };
}
