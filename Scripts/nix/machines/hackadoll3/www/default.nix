{ pkgs, config, lib, ... }:

# Note: this Caddy configuration is specifically made for Tailscale.
# It will NOT work with public IPs.

{
	imports = [
		./_module.nix
		./esp.nix
		./bulb.nix
	];

	diamond.tailnet-services = {
		test = {
			subdomains = [ "" "test" ];
			caddyConfig = ''
				respond "Hello from ${config.networking.hostName}!"
			'';
		};
	};
}
