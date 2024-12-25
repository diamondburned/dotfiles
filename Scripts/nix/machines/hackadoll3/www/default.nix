{
  pkgs,
  config,
  lib,
  ...
}:

# Note: this Caddy configuration is specifically made for Tailscale.
# It will NOT work with public IPs.

{
  imports = [
    ./modules.nix

    ./_comd.nix
  ];
}
