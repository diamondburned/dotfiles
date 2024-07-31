{ config, lib, pkgs, ... }:

with lib;
with lib.types;
with builtins;

let
	inherit (config.diamond)
		tailnetServices
		localhostConfig;

	hostname = config.networking.hostName;

	trailingDot = name: if name == "" then "" else "${name}.";
	trace' = x: trace x x;
in

{
	options.diamond = {
		tailnetServices = mkOption {
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
		localhostConfig = mkOption {
			description = "Additional Caddy configuration for the current host";
			type = types.str;
			default = '''';
		};
	};

	config = mkIf (tailnetServices != {}) {
		# Permit Caddy to use Tailscale for its certificates.
		services.tailscale.permitCertUid = "caddy";

		# Disable reloading.
		# This does not work with the Tailscale plugin.
		systemd.services.caddy.reloadIfChanged = lib.mkForce false;
		systemd.services.caddy.serviceConfig.ExecReload = lib.mkForce null;

		# TODO: set up caddy-tailscale.
	
		services.diamondburned.caddy = {
			enable = true;
			environmentFile = <dotfiles/secrets/caddy.env>;
			configFile = pkgs.writeText "Caddyfile" ''
				{
					auto_https off
				}
			'';
			sites.":80" = mapAttrsToList (name: service:
				let
					hosts = if (lib.isAttrs service && service.subdomains != []) then
						service.subdomains
					else
						[name];
				in
				''
					bind ${concatStringsSep " " (map (host: "tailscale/${host}") hosts)}
					${if (isString service) then
							service
						else
						''
							${optionalString
								(service.localPort != null)
								"reverse_proxy * localhost:${toString service.localPort}"}
							${service.caddyConfig}
						''}
				''
			) tailnetServices;
		};
	};
}
