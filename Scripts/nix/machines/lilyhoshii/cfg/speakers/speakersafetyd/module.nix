{ pkgs, lib, config, ... }:

with lib;
with builtins;

let
	self = config.services.speakersafetyd;

	prefixExtras = concatStringsSep "\n"
		(mapAttrsToList
			(name: path: ''
				install -m 644 \
					${path} \
					$out/share/speakersafetyd/${escapeShellArg name}.conf
			'')
			(self.extraConfig));

	prefix = pkgs.runCommandLocal "speakersafetyd-conf" {} ''
		mkdir -p $out/share/speakersafetyd
		install -m 644 ${self.package.src}/*.conf $out/share/speakersafetyd/
		${prefixExtras}
	'';
in

{
	options.services.speakersafetyd = {
		enable = mkEnableOption "Enable speakersafetyd";

		extraConfig = mkOption {
			type = types.attrsOf types.path;
			default = {};
			example = literalExpression ''
				{
					j313 = ./speakersafetyd/j313.conf;
					j314 = ./speakersafetyd/j314.conf;
				}
			'';
			description = "Extra configuration files to be installed";
		};

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
				${self.package}/bin/speakersafetyd -c ${prefix}/share/speakersafetyd
			'';
			after = [ "sound.target" ];
			wantedBy = [ "multi-user.target" ];
		};
	};
}
