{ pkgs, config, lib, ... }:

# Note: this Caddy configuration is specifically made for Tailscale.
# It will NOT work with public IPs.

{
	imports = [
		./_module.nix
		./comd.nix
		./esp.nix
		./bulb.nix
	];

	# diamond.tailnetServices = {
	# 	test = {
	# 		subdomains = [ "" "test" ];
	# 		caddyConfig = ''
	# 			respond "Hello from ${config.networking.hostName}!"
	# 		'';
	# 	};
	# };
}
