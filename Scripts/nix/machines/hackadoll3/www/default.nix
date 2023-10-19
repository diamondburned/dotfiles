{ pkgs, config, lib, ... }:

# Note: this Caddy configuration is specifically made for Tailscale.
# It will NOT work with public IPs.

let
	hostname = config.networking.hostName;

	trailingDot = name: if name == "" then "" else "${name}.";

	subdomain = name:
		with lib;
		concatStringsSep ", " [
			"http://${trailingDot name}${hostname}.ts.libdb.so"
			"http://${trailingDot name}${hostname}.ts.arikawa-hi.me"
			# "https://${optionalString (name != "") (name + ".")}${hostname}.ts.libdb.so"
			# "https://${optionalString (name != "") (name + ".")}${hostname}.ts.arikawa-hi.me"
		];

	subdomains = subdomains:
		with lib;
		concatStringsSep ", " (map subdomain subdomains);

	tailscaleTLS =
		with lib;
		with builtins;
		concatStringsSep " " [
			"${<dotfiles/secrets/ssl/skate-gopher.ts.net>}/${hostname}.skate-gopher.ts.net.crt"
			"${<dotfiles/secrets/ssl/skate-gopher.ts.net>}/${hostname}.skate-gopher.ts.net.key"
		];

	dynamicSubdomains = subdomains:
		with lib;
		concatStringsSep " " (map (name: "${trailingDot name}${hostname}.ts") subdomains);
in

{
	services.diamondburned.caddy = {
		enable = true;
		environmentFile = <dotfiles/secrets/caddy.env>;
		configFile = pkgs.writeText "Caddyfile" ''
			{
				auto_https off

				dynamic_dns {
					provider cloudflare {env.CLOUDFLARE_API_KEY}

					# Specifically use the Tailscale interface for its IP.
					ip_source interface tailscale0
					versions ipv4

					domains {
						# Specifically put the machine in .ts.libdb.so for Tailscale, as
						# opposed to .s.libdb.so, which is a direct IP alias.
						libdb.so      ${dynamicSubdomains ["" "test" "dol"]}
						arikawa-hi.me ${dynamicSubdomains ["" "test" "dol"]}
					}

					dynamic_domains
				}
			}
		'';
		sites = {
			${subdomains ["" "test"]} = ''
				# tls ${tailscaleTLS}
				respond "Hello from ${hostname}!"
			'';
			${subdomains ["dol"]} = ''
				# TODO: move this to a systemd service and use a reverse proxy to the
				# Unix socket.
				reverse_proxy * localhost:19384
			'';
		};
	};
}
