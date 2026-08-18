{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./security.nix
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
