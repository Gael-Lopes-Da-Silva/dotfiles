{ ... }:

{
  services = {
    polkit-gnome.enable = true;
    gnome-keyring.enable = true;
    ssh-agent.enable = true;
  };

  programs = {
    home-manager.enable = true;
    firefox.enable = true;
    zoxide.enable = true;
    fzf.enable = true;
  };
}
