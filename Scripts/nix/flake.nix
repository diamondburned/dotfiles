{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=5d67ea6b4b63378b9c13be21e2ec9d1afc921713"; # nixos-unstable
    flake-utils.url = "github:numtide/flake-utils";

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
          pkgs = mkPkgs system;
          system = "x86_64-linux";
          modules = [ ./machines/hackadoll3/configuration.nix ];
          specialArgs = mkNixOSArgs pkgs;
        };
        lilyhoshii = nixpkgs.lib.nixosSystem rec {
          pkgs = mkPkgs system;
          system = "aarch64-linux";
          modules = [ ./machines/lilyhoshii/configuration.nix ];
          specialArgs = mkNixOSArgs pkgs;
        };
      };

      mkNixOSArgs = pkgs: {
        inherit self;
        inputs = combinedInputs pkgs;
        utils = import ./utils { inherit pkgs; };
      };

      mkDevShell =
        pkgs:
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

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
          overlays = [
            self.overlays.overrides
            self.overlays.packages
            inputs.gomod2nix.overlays.default
          ];
        };

      packages = eachDefaultSystem (
        pkgs:
        import ./overlays/packages.nix {
          inherit pkgs;
          inputs = combinedInputs pkgs;
        }
      );

      overlays = {
        overrides = import ./overlays/overrides.nix;
        packages =
          _: pkgs:
          import ./overlays/packages.nix {
            inherit pkgs;
            inputs = combinedInputs pkgs;
          };
      };

      nixosModules = (searchModules "default.nix") // {
        # Add missing modules here.
        overlays = import ./overlays/services.nix;
      };

      homeModules = (searchModules "home.nix") // {
        # Add missing modules here.
      };

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
        pkgs:
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
        pkgsFunc:
        builtins.listToAttrs (
          map (system: {
            name = system;
            value = pkgsFunc (mkPkgs system);
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
    };
}
