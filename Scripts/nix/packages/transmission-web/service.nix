{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.transmission-web;
	trs = config.services.transmission;

in {
	options.services.transmission-web = {
		enable = mkEnableOption "Enable the Nixie Discord bot";

		config = mkOption {
			type = types.attrs;
			description = "The JSON configuration for transmission-web.";
		};

		package = mkOption {
			default = pkgs.callPackage ./default.nix {};
			type = types.package;
		};
	};

	config = mkMerge [(mkIf cfg.enable (
		let configPath = builtins.toFile "config.json" (builtins.toJSON (cfg.config // {
				transmission = {
					Username = trs.settings.rpc-username;
					Password = trs.settings.rpc-password;
					Address  = trs.settings.rpc-whitelist;
					Port  = trs.port;
					HTTPS = false;
				};
			}));

		in {
			users.users.transmission.group = "transmission";
			users.users.transmission.createHome = true;
		
			users.groups.transmission = {};
		
			systemd.services.transmission-web = {
				enable = true;
				description = "Transmission Web UI daemon";
				after    = [ "network-online.target" "transmission.service" ];
				wantedBy = [ "multi-user.target" ];
				serviceConfig = {
					User  = "transmission";
					Group = "transmission";
					ExecStart  = "${cfg.package}/bin/transmission-web -path ${configPath}";
					KillSignal = "SIGINT";
					KillMode = "mixed";
					RestartSec = "3";
					LimitMEMLock = 1024 * 1024 * 1024 * 1;
				};
			};
		}
	))];
}
