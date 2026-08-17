{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./security.nix
  ];

  environment.systemPackages = with pkgs; [
    llama-cpp

    code-cursor
  ];

  services = {
    tlp.enable = true;
    auto-cpufreq.enable = true;
  };
}
