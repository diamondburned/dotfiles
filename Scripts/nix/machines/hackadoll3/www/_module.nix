{ config, lib, pkgs, ... }:

with lib;
with lib.types;
with builtins;

let
	self = config.diamond.tailnet-services;

	services = mapAttrsToList (name: service: {
		subdomains =
			if (lib.isAttrs service && service.subdomains != []) then
				service.subdomains
			else
				[name];
		caddyConfig =
			if (isString service) then
				service
			else
			''
				${optionalString
					(service.localPort != null)
					"reverse_proxy * localhost:${toString service.localPort}"}
				${service.caddyConfig}
			'';
	}) self;

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

	dynamicSubdomains = domains: subdomains:
		with lib;
		let
			generate = domain:
				(domain + " ") +
				(concatStringsSep " " (map (name: "${trailingDot name}${hostname}.ts") subdomains));
		in
			concatStringsSep "\n" (map generate domains);

	trace' = x: trace x x;
in

{
	options.diamond.tailnet-services = mkOption {
		description = "Declare local services via Caddy and Tailscale";
		type = attrsOf (either str (submodule {
			options = {
				subdomains = mkOption {
					type = types.listOf types.str;
					default = [];
					description = "The subdomains to use for the service, or null to use the service name";
				};
				localPort = mkOption {
					type = types.nullOr types.int;
					default = null;
					description = "The port to reverse proxy to";
				};
				caddyConfig = mkOption {
					type = types.str;
					default = "";
					description = "Additional Caddy configuration";
				};
			};
		}));
	};

	config = mkIf (self != {}) {
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
							${dynamicSubdomains
								domains
								(flatten
									(map (service: service.subdomains) services))
							}
						}
					}
				}
			'';
			sites = listToAttrs (map (service: {
				name  = subdomains service.subdomains;
				value = service.caddyConfig;
			}) services);
		};
	};
}
