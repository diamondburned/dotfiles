{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=5d67ea6b4b63378b9c13be21e2ec9d1afc921713"; # nixos-unstable

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    {
      nixosConfigurations = {
        hackadoll3 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./machines/hackadoll3/configuration.nix ];
        };
        lilyhoshii = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [ ./machines/lilyhoshii/configuration.nix ];
        };
      };
    }
    // (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      { }
    ));
}
