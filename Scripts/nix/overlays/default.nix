{
  lib,
  pkgs,
  self,
  inputs,
  ...
}:

let
  inherit (inputs)
    nixpkgs
    home-manager
    ;

  overlays = [
    self.overlays.overrides
    self.overlays.packages

    # lib already overridden by flake.nix's specialArgs.
    (final: prev: { inherit lib; })
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
