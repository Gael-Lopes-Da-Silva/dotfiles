{
  description = "Gael's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
  in
  {
    nixpkgs.config.allowUnfree = true;
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/laptop
          ./modules

          home-manager.nixosModules.home-manager
        ];
      };

      desktop = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ./hosts/desktop
          ./modules

          home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}
