{
  description = "Gael's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";

      mkHost =
        hostPath:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            home-manager.nixosModules.home-manager
            {
              nixpkgs.config.allowUnfree = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
            hostPath
            ./modules
            ./home
          ];
        };
    in
    {
      nixosConfigurations = {
        laptop = mkHost ./hosts/laptop;
        desktop = mkHost ./hosts/desktop;
      };
    };
}
