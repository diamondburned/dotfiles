{ pkgs, config, lib, ... }:

# Note: this Caddy configuration is specifically made for Tailscale.
# It will NOT work with public IPs.

let
	hostname = config.networking.hostName;

	subdomain = name:
		with lib;
		concatStringsSep ", " [
			"${optionalString (name != "") (name + ".")}${hostname}.ts.libdb.so"
			"${optionalString (name != "") (name + ".")}${hostname}.ts.arikawa-hi.me"
		];

	subdomains = subdomains:
		with lib;
		concatStringsSep ", " (map subdomain subdomains);

	tailscaleTLS =
		with lib;
		with builtins;
		concatStringsSep " " [
			"${toString <dotfiles/secrets/ssl/skate-gopher.ts.net>}/${hostname}.skate-gopher.ts.net.crt"
			"${toString <dotfiles/secrets/ssl/skate-gopher.ts.net>}/${hostname}.skate-gopher.ts.net.key"
		];
in

{
	services.diamondburned.caddy = {
		enable = true;
		# Use builtins.toString so that the file does not get included in the
		# closure. Caddy will directly read the file from the filesystem.
		environmentFile = builtins.toString <dotfiles/secrets/dns.nix>;
		configFile = pkgs.writeText "Caddyfile" ''
			{
				dynamic_dns {
					provider cloudflare {env.CLOUDFLARE_API_KEY}

					# Specifically use the Tailscale interface for its IP.
					ip_source interface tailscale0
					versions ipv4

					domains {
						# Specifically put the machine in .ts.libdb.so for Tailscale, as opposed to .s.libdb.so,
						# which is a direct IP alias
						libdb.so      ${hostname}.ts
						arikawa-hi.me ${hostname}.ts
					}
					dynamic_domains
				}
			}
		'';
		sites = {
			${subdomains ["" "test"]} = ''
				tls ${tailscaleTLS}
				respond "Hello from ${hostname}!"
			'';
		};
	};
}
