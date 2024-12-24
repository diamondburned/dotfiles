{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=5d67ea6b4b63378b9c13be21e2ec9d1afc921713"; # nixos-unstable
    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs = {
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gomod2nix.url = "github:nix-community/gomod2nix";
    gomod2nix.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
      ...
    }@inputs:

    let
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
      nixosConfigurations = {
        hackadoll3 = nixpkgs.lib.nixosSystem rec {
          pkgs = mkPkgs system;
          system = "x86_64-linux";
          modules = [ ./machines/hackadoll3/configuration.nix ];
          specialArgs = {
            inherit self;
            inputs = combinedInputs;
          };
        };
        lilyhoshii = nixpkgs.lib.nixosSystem rec {
          pkgs = mkPkgs system;
          system = "aarch64-linux";
          modules = [ ./machines/lilyhoshii/configuration.nix ];
          specialArgs = {
            inherit self;
            inputs = combinedInputs;
          };
        };
      };

      devShells =
        let
          devShell =
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

                # (writeShellScriptBin "switch" ''
                #   export NIX_PATH=${lib.escapeShellArg nixPath}
                #   sudo nixos-rebuild --log-format internal-json -v "$@" switch |& nom --json
                # '')
              ];
            };
        in
        eachDefaultSystem (pkgs: {
          default = devShell pkgs;
        });

      packages = eachDefaultSystem (
        pkgs:
        import ./overlays/packages.nix {
          inherit pkgs;
          inputs = combinedInputs;
        }
      );

      overlays = {
        overrides = import ./overlays/overrides.nix;
        packages =
          _: pkgs:
          import ./overlays/packages.nix {
            inherit pkgs;
            inputs = combinedInputs;
          };
      };
    };
}
