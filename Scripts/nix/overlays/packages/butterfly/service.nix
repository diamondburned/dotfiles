{ config, lib, pkgs, ... }:

with lib;

let toEnv = x: concatStringsSep "\n" (mapAttrsToList (k: v: "${k}=\"${v}\"") x);

in {
	options.services.butterfly = {
		enable = mkEnableOption "Butterfly Discord bot.";

		config = mkOption {
			type = types.attrs;
			description = "Bot config.";
		};
	};

	config = mkMerge [(mkIf config.services.butterfly.enable (
		let home = "/opt/butterfly";
			cfg = config.services.butterfly;
			src = builtins.fetchGit {
				url = "https://gitlab.com/diamondburned/butterfly.git";
				ref = "master";
				rev = "b2512ef59e3bfcef6ba2b228b32107767de17b9b";
			};
			configFile = pkgs.writeScript "config" (toEnv (cfg.config // {
				PATH = "${home}/bin:$PATH";
			}));
			# Script to update source code and install dependencies.
			install = pkgs.writeScript "butterfly.sh" ''
				# Check if package is up-to-date
				[[ ! -f .rev || $(< .rev) != ${src.rev} ]] && {
					# Sync without preserving user and group.
					rsync -rptDvu ${src}/ ./

					# Correct permissions.
					chmod -R  0744                ./ || true
					chown -Rh butterfly:butterfly ./ || true

					# Save the commit hash.
					echo -n ${src.rev} > .rev
				}

				# Sync the config afterwards.
				cp ${configFile} ./config
				chmod 0700 ./config

				# Install dependencies.
				npm install
			'';

		in {
			users.groups.butterfly = {};
			users.users.butterfly = {
				group = "butterfly";
				home  = home;
				createHome = true;
			};
	
			# Redis dependency ._.
			services.redis.enable = true;
	
			systemd.tmpfiles.rules = [
				# Premake the osu directory to avoid permission overwrite
				"d ${home}/osu 0744 butterfly butterfly -"
				# install oppai
				"L ${home}/osu/oppai - - - - ${pkgs.oppai-ng}/bin/oppai"
				# make a self-cleanup (7 days) tmp directory
				"d ${home}/tmp 0744 butterfly butterfly 7d"
			];
	
			systemd.services.butterfly = {
				enable = true;
				wantedBy = [ "multi-user.target" "systemd-tmpfiles-setup.service" ];
				after = [ "network.target" "redis.service" ];
				serviceConfig = {
					User  = "butterfly";
					Group = "butterfly";
					WorkingDirectory = home;
					ExecStartPre = "${pkgs.bash}/bin/bash ${install}";
					ExecStart    = "${pkgs.nodejs}/bin/node ${home}/bot.js";
					KillSignal   = "SIGINT";
					KillMode     = "mixed";
					RestartSec   = "5";
					LimitMEMLOCK = 1 * 1024 * 1024 * 1024; # 1GB
					TimeoutStopSec = "10";
				};
				path = with pkgs; [
					coreutils-full
					utillinux
					nodejs
					rsync
					bash
					wget
					redis
					bc
					gnuplot
					curl
					git
					oppai-ng
				];
			};
		}
	))];
}
