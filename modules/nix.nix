{ ... }:

{
  nix = {
    optimise = {
      automatic = true;
      persistent = true;
      dates = "daily";
    };

    settings = {
      cores = 8;
      max-jobs = "auto";
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [
        "root"
        "gael"
      ];
    };

    gc = {
      automatic = true;
      persistent = true;
      dates = "daily";
      options = "--delete-older-than 5d";
    };
  };
}
