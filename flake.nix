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

    mkHost = hostModule:
      nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          {
            nixpkgs.config.allowUnfree = true;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }

          ./modules
          hostModule

          home-manager.nixosModules.home-manager
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
