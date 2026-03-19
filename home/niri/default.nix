{ ... }:

{
  wayland.systemd.target = "niri.service";

  home.file.".config/niri/config.kdl".source = ./config.kdl;
}
