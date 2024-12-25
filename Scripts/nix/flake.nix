{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    gomod2nix.url = "github:nix-community/gomod2nix";
    gomod2nix.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    globset.url = "github:pdtpartners/globset";
    globset.inputs = {
      nixpkgs-lib.follows = "nixpkgs";
    };

    nixgl.url = "github:nix-community/nixgl";
    nixgl.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    nix-bonito.url = "github:diamondburned/nix-bonito";
    nix-bonito.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };

    comd.url = "github:diamondburned/comd";
    comd.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    disko.inputs = {
      nixpkgs.follows = "nixpkgs";
    };

    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-compat.follows = "flake-compat";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
      globset,
      ...
    }@inputs:

    let
      nixosConfigurations = {
        hackadoll3 = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules = [
            ./machines/base.nix
            ./machines/hackadoll3/configuration.nix
          ];
          specialArgs = mkNixOSArgs {
            inherit system;
          };
        };
        lilyhoshii = nixpkgs.lib.nixosSystem rec {
          system = "aarch64-linux";
          modules = [
            ./machines/base.nix
            ./machines/lilyhoshii/configuration.nix
          ];
          specialArgs = mkNixOSArgs {
            inherit system;
          };
        };
      };

      mkNixOSArgs =
        { system }:
        {
          inherit self;
          inputs = combinedInputs {
            pkgs = nixpkgs.legacyPackages.${system};
          };
        };

      mkDevShell =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              inputs.gomod2nix.overlays.default
              self.overlays.overrides
              self.overlays.packages
            ];
          };
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            bonito
            disko
            niv
            git
            git-crypt
            gomod2nix
            nixfmt-rfc-style
            nix-output-monitor
            lua-language-server
          ];
        };

      packages = eachDefaultSystem (
        system:
        self.overlays.packages null (
          import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              inputs.gomod2nix.overlays.default
              self.overlays.overrides
            ];
          }
        )
      );

      overlays = {
        overrides = import ./overlays/overrides.nix;
        packages =
          final: prev:
          import ./overlays/packages.nix {
            pkgs = prev;
            inputs = combinedInputs {
              pkgs = prev;
            };
          };
      };

      nixosModules = (searchModules "default.nix") // {
        overlays = import ./overlays;
      };

      homeModules = (searchModules "home.nix") // { };

      searchModules =
        with builtins;
        with nixpkgs.lib;
        nixFile:
        let
          root = ./modules;
          modules = nixpkgs.lib.fileset.toSource {
            inherit root;
            fileset = globset.lib.glob root "*/${nixFile}";
          };
        in
        mapAttrs (name: _: import (root + "/${name}/${nixFile}")) (builtins.readDir modules);

      # combinedInputs contains all the inputs from the flake and the niv inputs
      # updated using `niv` commands.
      combinedInputs =
        { pkgs }:
        { }
        # Mark Niv inputs with a _type:
        // (nixpkgs.lib.mapAttrs (_: src: src // { _type = "niv"; }) (
          import "${self}/nix/sources.nix" {
            inherit (pkgs) system;
          }
        ))
        # Flake inputs are already marked with a _type:
        // (inputs);

      eachDefaultSystem =
        systemFunc:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = systemFunc system;
          }) flake-utils.lib.defaultSystems
        );
    in
    {
      inherit nixosConfigurations;

      inherit nixosModules;
      inherit homeModules;

      inherit packages;
      inherit overlays;

      devShells = eachDefaultSystem (pkgs: {
        default = mkDevShell pkgs;
      });

      lib = rec {
        path = {
          bin = path: ./bin + ("/" + path);
          static = path: ./static + ("/" + path);
          secret = path: ./secrets + ("/" + path);
        };
      };
    };
}
