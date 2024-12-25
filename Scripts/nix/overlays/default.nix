{ pkgs, inputs, ... }:

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

  nixpkgs.overlays = [
    # packages
    (
      self: super:
      import ./packages.nix {
        inherit inputs;
        pkgs = super;
      }
    )

    # lib
    (self: super: {
      lib = super.lib.extend (
        selflib: superlib: {
          x = import ./lib/x.nix {
            inherit inputs;
            pkgs = super;
          };
        }
      );
    })
  ];
}
