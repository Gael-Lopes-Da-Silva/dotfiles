{ ... }:

{
  imports = [
    ./hardware.nix
    ./wireguard.nix
  ];

  networking.hostName = "windows11";
}
