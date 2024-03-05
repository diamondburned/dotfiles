{ ... }: 

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
}
