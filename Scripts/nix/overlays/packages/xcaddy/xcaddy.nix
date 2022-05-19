{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.diamondburned.xcaddy;
	withArgs = concatMapStrings (str: "--with ${escapeShellArg str}") cfg.plugins;
	configFile = pkgs.writeText "caddyconfig" cfg.config;

in {
	options.services.diamondburned.xcaddy = {
		enable = mkEnableOption "Caddy web server and plugin manager";

		config = mkOption {
			default = "";
			example = ''
				example.com {
					gzip
					minify
					log syslog

					root /srv/http
				}
			'';
			type = types.lines;
			description = "Configuration file to use with adapter";
		};

		plugins = mkOption {
			default = [];
			example = [
				"github.com/caddyserver/caddy/v2@v2.4.3"
				"github.com/caddyserver/ntlm-transport"
			];
			type = types.listOf types.str;
			description = "Arguments to pass into --with flags";
		};

		readWritePaths = mkOption {
			default = "";
			type = types.str;
			description = "See man systemd.exec on ReadWritePaths";
		};

		adapter = mkOption {
			default = "caddyfile";
			type = types.str;
			description = "Type of config given";
		};

		package = mkOption {
			default = (pkgs.callPackage ./default.nix {});
			type = types.package;
			description = "Caddy package to use.";
		};
	};

	config = mkIf cfg.enable {
		systemd.services.xcaddy = {
			description = "Caddy web server and plugin manager";
			after    = [ "network-online.target" ];
			wantedBy = [ "multi-user.target"     ];
			reloadIfChanged = true;
			serviceConfig = {
				ExecStartPre = ''
					${cfg.package}/bin/xcaddy build --output $CACHE_DIRECTORY/caddy ${withArgs}
				'';
				ExecStart = ''
					$CACHE_DIRECTORY/caddy run --config  ${configFile} --adapter ${cfg.adapter}
				'';
				ExecReload = ''
					$CACHE_DIRECTORY/caddy reload --config  ${configFile} --adapter ${cfg.adapter}
				'';
				ExecStop = ''
					$CACHE_DIRECTORY/caddy stop
				'';
				Type  = "simple";
				User  = "caddy";
				Group = "caddy";
				Restart = "on-failure";
				AmbientCapabilities   = [ "cap_net_bind_service" "cap_net_raw" ];
				CapabilityBoundingSet = [ "cap_net_bind_service" "cap_net_raw" ];
				NoNewPrivileges = true;
				LimitNPROC  = 8192;
				LimitNOFILE = 1048576;
				PrivateTmp     = false;
				PrivateDevices = true;
				ProtectHome    = "read-only";
				ProtectSystem  = "strict";
				ReadWritePaths = "/run /var/lib/caddy ${cfg.readWritePaths}";
			};
		};

		users.users.caddy = {
			group = "caddy";
			uid = config.ids.uids.caddy;
			home = "/var/lib/caddy";
			createHome = true;
		};

		users.groups.caddy.gid = config.ids.uids.caddy;
	};
}
