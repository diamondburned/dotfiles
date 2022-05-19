{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.ghproxy;

in {
	options.services.ghproxy = {
		username = mkOption {
			default = "";
			type = types.str;
			description = "Username of the GitHub profile.";
		};

		address = mkOption {
			default = "";
			example = "tcp://127.0.0.1:0";
			type = types.str;
			description = ''
				Address to listen HTTP to. Use /run/ghproxy/name.sock if Unix,
				which will expose the socket under the same directory outside.
			'';
		};

		package = mkOption {
			default = pkgs.ghproxy;
			type = types.package;
			description = "Caddy package to use.";
		};
	};

	config = mkIf (cfg.username != "" && cfg.address != "") {
		systemd.services.ghproxy = {
			description = "GitHub single profile proxy";
			after    = [ "network-online.target" ];
			wantedBy = [ "multi-user.target"     ];
			environment = {
				GHPROXY_USERNAME = cfg.username;
				GHPROXY_ADDRESS  = cfg.address;
			};
			serviceConfig = {
				Type = "simple";
				Restart = "on-failure";
				ExecStart   = "${cfg.package}/bin/ghproxy";
				DynamicUser = "yes";
				LimitNPROC  = 8192;
				LimitNOFILE = 1048576;
				PrivateDevices = true;
				ProtectHome    = true;
				NoNewPrivileges  = true;
				RuntimeDirectory = "ghproxy";
				RuntimeDirectoryMode = "0777";
			};
		};
	};
}
