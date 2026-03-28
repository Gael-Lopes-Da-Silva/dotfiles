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
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.config.allowUnfree = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }

            ./hosts/laptop
            ./modules
            ./home
          ];
        };
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.config.cudaSupport = true;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }

            ./hosts/desktop
            ./modules
            ./home
          ];
        };
      };
    };
}
