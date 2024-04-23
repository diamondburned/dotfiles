{ pkgs, config, lib, ... }:

# Note: this Caddy configuration is specifically made for Tailscale.
# It will NOT work with public IPs.

let
	hostname = config.networking.hostName;

	trailingDot = name: if name == "" then "" else "${name}.";

	domains = [
		"libdb.so"
		"dia.cat"
		"diamondx.pet"
	];

	subdomain = name:
		with lib;
		concatStringsSep ", " [
			"http://${trailingDot name}${hostname}.ts.libdb.so"
			"http://${trailingDot name}${hostname}.ts.dia.cat"
			"http://${trailingDot name}${hostname}.ts.diamondx.pet"
			"http://${name}"
		];

	subdomains = subdomains:
		with lib;
		with builtins;
		concatStringsSep ", " (map subdomain subdomains);

	bulbremote = pkgs.fetchzip {
		url = "https://github.com/diamondburned/bulbremote/releases/download/v0.0.3/dist.tar.gz";
		sha256 = "sha256-V4DbvuiKDi6fUhVp74AQJll/AWY+SRCkMALDNjG/7ZE=";
	};

	dynamicSubdomains = domains: subdomains:
		with lib;
		let
			generate = domain:
				(domain + " ") +
				(concatStringsSep " " (map (name: "${trailingDot name}${hostname}.ts") subdomains));
		in
			concatStringsSep "\n" (map generate domains);
in

{
	# Permit Caddy to use Tailscale for its certificates.
	services.tailscale.permitCertUid = "caddy";

	# TODO: set up caddy-tailscale.

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
						${dynamicSubdomains domains ["" "test" "dol" "bulb" "esp" "trilium"]}
					}

					dynamic_domains
				}
			}
		'';
		sites = {
			${subdomains ["" "test"]} = ''
				respond "Hello from ${hostname}!"
			'';
			${subdomains ["dol"]} = ''
				# TODO: move this to a systemd service and use a reverse proxy to the
				# Unix socket.
				# reverse_proxy * localhost:19384
				reverse_proxy * unix//tmp/dol-server.sock
			'';
			${subdomains ["bulb"]} =
				let
					secrets = import ./secrets/bulbremote.nix;
					configJSON = builtins.toJSON {
						JSONBIN_ID = secrets.jsonbinID;
						JSONBIN_TOKEN = secrets.jsonbinToken;
					};
				in
				''
					handle * {
						root * ${bulbremote}
						file_server
					}
					handle /api/config {
						respond `${configJSON}`
					}
					handle /api/command {
						method * GET
						rewrite * /cm?cmnd={query.cmnd}
						reverse_proxy * ${secrets.tasmotaAddress}
					}
				'';
			${subdomain "esp"} =
				let
					index = pkgs.writeText "index.html" ''
						<!DOCTYPE html>
						<title>Tasmota Index</title>
						<meta charset="utf-8">
						<meta name="viewport" content="width=device-width, initial-scale=1">
						<link rel="icon" type="image/png" href="/favicon.png">
						<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/normalize.css@8.0.1/normalize.css">
						<link rel="stylesheet" href="https://markdowncss.github.io/retro/css/retro.css">
						<style>
							body {
								font-family: monospace !important;
							}
						</style>

						<h1>Tasmota Index</h1>
						<ul>
							<li><a href="/bulb">Tasmota Bulb</a></li>
							<li><a href="/plug">Tasmota Plug</a></li>
						</ul>
					'';
					fs = pkgs.runCommandLocal "esp-fs" {
					} ''
						mkdir -p $out
						ln -s ${index} $out/index.html
						ln -s ${<dotfiles/static/tasmota-white.png>} $out/favicon.png
					'';
				in ''
					redir /bulb http://192.168.2.124:80 302
					redir /plug http://192.168.2.239:80 302
					root * ${fs}
					file_server
				'';
			${subdomain "trilium"} = ''
				reverse_proxy * localhost:${config.services.trilium-server.port}
			'';
		};
	};
}
