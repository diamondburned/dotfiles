{ ... }:

{
  imports = [
    ./transmission-web/service.nix
    ./nixie/service.nix
    ./butterfly/service.nix
    ./caddy/caddy.nix
    ./xcaddy/xcaddy.nix
    ./caddyv1/caddy.nix
    ./ghproxy/ghproxy.nix
    ./drone-ci/drone-ci.nix
  ];
}
