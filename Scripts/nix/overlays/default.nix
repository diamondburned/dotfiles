{ pkgs, inputs, ... }:

let
  overlays = [
    # packages
    (
      self: super:
      import ./packages.nix {
        inherit inputs;
        pkgs = super;
      }
    )

    # lib
    (_: prev: {
      lib = prev.lib.extend (
        _: prevlib: {
          x = import ./lib/x.nix {
            pkgs = prev;
            lib = prevlib;
          };
        }
      );
    })
  ];
in

{
  imports = [
    ./packages/transmission-web/service.nix
    ./packages/nixie/service.nix
    ./packages/butterfly/service.nix
    ./packages/caddy/caddy.nix
    ./packages/xcaddy/xcaddy.nix
    ./packages/caddyv1/caddy.nix
    ./packages/ghproxy/ghproxy.nix
    ./packages/drone-ci/drone-ci.nix
    ./packages/realtek/realtek.nix
  ];

  nixpkgs = {
    inherit overlays;
  };

  home-manager.sharedModules = [
    {
      nixpkgs = {
        inherit overlays;
      };
    }
  ];
}
