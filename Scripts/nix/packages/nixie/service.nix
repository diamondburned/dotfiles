{ config, lib, pkgs, ... }:

with lib;

{
	options.services.nixie = {
		enable = mkEnableOption "NixHub Discord bot.";

		token = mkOption {
			type = types.str;
			description = "Bot token without the Bot prefix.";
		};

		commit = mkOption {
			type = types.str;
			default = "0c1661c78e6459a2d5f0221a130a050b2c4a6dd3";
		};
		modSha256 = mkOption {
			type = types.str;
		};

		dataDir = mkOption {
			default = "/var/db/nixie";
			type = types.path;
			description = "Working directory for the bot.";
		};
	};

	config = mkMerge [(
		let cfg = config.services.nixie;
			pkg = pkgs.buildGoModule {
				name    = "nixie";
				version = "0.0.1";

				src = builtins.fetchGit {
					url = "https://gitlab.com/diamondburned/nixie.git";
					rev = cfg.commit;
				};
				vendorHash = cfg.modSha256;

				subPackages = [ "." ];
				meta = {
					description = "NixHub Discord bot";
					homepage    = "https://nixhub.io";
				};
			};
		
		in (mkIf cfg.enable {
			users.groups.nixie = {};
			users.users.nixie = {
				group = "nixie";
				home = cfg.dataDir;
				createHome = true;
				isSystemUser = true;
			};

			systemd.services.nixie = {
				description = "NixHub Discord bot service";
				after       = [ "network-online.target" ];
				wantedBy    = [ "multi-user.target" ];
				environment = {
					BOT_TOKEN = cfg.token;
				};
				unitConfig = {
					StartLimitBurst    = 1; # once
					StartLimitInterval = 5; # max 5 tries.
				};
				serviceConfig = {
					ExecStart = "${pkg}/bin/nixie";	
					Type  = "simple";
					User  = "nixie";
					Group = "nixie";
					Restart = "on-failure";
					WorkingDirectory = cfg.dataDir; # user home directory
					# https://discordapp.com/developers/docs/topics/gateway#rate-limiting
					RestartSec = 5; # per 5 seconds
				};
			};
		})
	)];
}
