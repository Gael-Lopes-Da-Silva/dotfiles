{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./security.nix
  ];

  environment.systemPackages = with pkgs; [
    llama-cpp

    cursor-cli
    code-cursor

    opencode
    opencode-desktop
  ];

  services = {
    tlp.enable = true;
    auto-cpufreq.enable = true;
  };
}
