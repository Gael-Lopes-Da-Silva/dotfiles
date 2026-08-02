{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./security.nix
  ];

  environment.systemPackages = with pkgs; [
    llama-cpp
  ];

  services = {
    tlp.enable = true;
    auto-cpufreq.enable = true;
    llama-cpp.enable = true;
  };
}
