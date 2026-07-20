{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
  ];

  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];

  networking = {
    hostName = "windows11";

    wg-quick.interfaces.wg0 = {
      address = [ "10.8.0.3/32" ];
      mtu = 1420;

      privateKeyFile = "/home/gael/.config/wireguard/gael.key";

      peers = [
        {
          publicKey = "Bqt6sSxpSYf7lpon+ufSsgxxeVRykffmgnbrSBOnzT8=";
          endpoint = "46.105.79.118:51820";
          allowedIPs = [
            "10.0.0.0/16"
            "10.8.0.0/24"
          ];
          persistentKeepalive = 25;
        }
      ];
    };
  };

  services = {
    tlp.enable = true;
    auto-cpufreq.enable = true;
    ollama.enable = true;
  };
}
