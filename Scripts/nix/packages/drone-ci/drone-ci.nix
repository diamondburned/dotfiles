{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.drone-ci;

in {
	options.services.drone-ci = {
		enable = mkEnableOption "Drone CI service.";

		config = mkOption {
			type = types.attrsOf types.string;
			example = {
				DRONE_GITHUB_SERVER = "https://github.com";
			};
		};

		package = mkOption {
			default = pkgs.drone-ci;
			type = types.package;
		};
	};

	config = mkIf cfg.enable {
		systemd.services.drone-ci = {
			description = "Drone CI server service.";
			after       = [ "network-online.target" ];
			wantedBy    = [ "multi-user.target" ];
			environment = cfg.config;
			serviceConfig = {
				Restart     = "on-failure";
				ExecStart   = "${cfg.package}/bin/drone-server";	
				DynamicUser = true;
			};
		};
	};
}
