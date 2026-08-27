{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./wireguard.nix
  ];

  environment.systemPackages = with pkgs; [
    llama-cpp
    cursor-cli
  ];

  services = {
    tlp.enable = true;
    auto-cpufreq.enable = true;
  };
}
