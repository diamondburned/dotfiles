{ pkgs, lib, config, ... }:

with lib;
with builtins;

let
	self = config.services.speakersafetyd;

	prefix = pkgs.runCommandLocal "speakersafetyd-conf" {} ''
		mkdir -p $out/share/speakersafetyd
		cp -r ${self.package.src}/conf/apple $out/share/speakersafetyd/
	'';
in

{
	options.services.speakersafetyd = {
		enable = mkEnableOption "Enable speakersafetyd";

		# extraConfig = mkOption {
		# 	type = types.attrsOf types.path;
		# 	default = {};
		# 	example = literalExpression ''
		# 		{
		# 			j313 = ./speakersafetyd/j313.conf;
		# 			j314 = ./speakersafetyd/j314.conf;
		# 		}
		# 	'';
		# 	description = "Extra configuration files to be installed";
		# };

		package = mkOption {
			type = types.package;
			default = pkgs.speakersafetyd;
			description = "The name of the speakersafetyd package";
		};
	};

	config = mkIf config.services.speakersafetyd.enable {
		nixpkgs.overlays = [
			(self: super: {
				speakersafetyd = super.callPackage ./package.nix {};
			})
		];

		systemd.services.speakersafetyd = {
			enable = true;
			script = ''
				${self.package}/bin/speakersafetyd \
					-c ${prefix}/share/speakersafetyd \
					-b /var/lib/speakersafetyd/blackbox \
					-m 7
			'';
			after = [ "sound.target" ];
			wantedBy = [ "multi-user.target" ];
			description = "Speaker Protection Daemon";
			serviceConfig = {
				UMask = "0066";
				Restart = "on-failure";
				RestartSec = 1;
				StartLimitInterval = 60;
				StartLimitBurst = 10;
			};
		};
	};
}
