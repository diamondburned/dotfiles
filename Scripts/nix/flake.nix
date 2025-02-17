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

    nixos-apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
    nixos-apple-silicon.inputs = {
      nixpkgs.follows = "nixpkgs";
      flake-compat.follows = "flake-compat";
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
      mkPackages =
        pkgs:
        import ./packages/all-packages.nix {
          pkgs = pkgs.appendOverlays [
            inputs.gomod2nix.overlays.default
            self.overlays.overrides
          ];
          inputs = self.lib.combinedInputs {
            inherit pkgs inputs;
          };
        };
    in
    {
      nixosConfigurations =
        nixpkgs.lib.flip nixpkgs.lib.mapAttrs
          {
            # Desktops
            hackadoll3 = {
              system = "x86_64-linux";
            };
            lilyhoshii = {
              system = "aarch64-linux";
            };
          }
          (
            machine:
            {
              system,
            }:
            nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                ./machines/base.nix
                ./machines/${machine}/configuration.nix
              ];
              specialArgs = {
                inherit self;
                inputs = self.lib.combinedInputs {
                  pkgs = nixpkgs.legacyPackages.${system};
                  inherit inputs;
                };
                lib = nixpkgs.lib.extend (
                  final: prev:
                  {
                    # extra system utilities.
                    x = import ./overlays/lib/x.nix {
                      pkgs = nixpkgs.legacyPackages.${system};
                      lib = prev;
                    };
                    inherit (self.lib) path;
                  }
                  // home-manager.lib
                );
              };
            }
          );

      nixosModules = self.lib.searchModules {
        root = ./modules;
        nixFile = "default.nix";
        extraModules = {
          packages = import ./packages;
        };
      };

      homeModules = self.lib.searchModules {
        root = ./modules;
        nixFile = "home.nix";
      };

      packages = self.lib.systems.eachSystem (
        system:
        mkPackages (
          import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          }
        )
      );

      overlays = {
        overrides = import ./overlays/overrides.nix;
        packages = (final: prev: mkPackages prev);
      };

      devShells = self.lib.systems.eachSystemAsDefault (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              inputs.gomod2nix.overlays.default
              self.overlays.overrides
              self.overlays.packages
            ];
            config.allowUnfree = true;
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
        }
      );

      lib = {
        combinedInputs = import ./nix/lib/combined-inputs.nix;
        searchModules = import ./nix/lib/search-modules.nix inputs;
        systems = import ./nix/lib/systems.nix inputs;

        path = {
          bin = path: ./bin + ("/" + path);
          static = path: ./static + ("/" + path);
          secret = path: ./secrets + ("/" + path);
        };
      };
    };
}
