{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
	self = config.programs.firefox.asahiWidevine;
	widevinecdm-package = pkgs.callPackage ./asahi-widevinecdm-package.nix { };
in

{
	options.programs.firefox.profiles = mkOption {
		type = types.attrsOf (types.submodule {
			options = {
				asahiWidevine = mkOption {
					type = types.submodule {
						options = {
							enable = mkEnableOption "Enable Widevine DRM support for this profile";

							package = mkOption {
								type = types.str;
								default = widevinecdm-package;
								description = "Widevine CDM package to use";
							};
						};
					};
				};
			};
		});
	};

	config = mkMerge (mapAttrs (_: profile: {
		programs.firefox.profiles."${profile.name}".settings = {
			"media.gmp-widevinecdm.version" = self.package.version;
			"media.gmp-widevinecdm.visible" = true;
			"media.gmp-widevinecdm.enabled" = true;
			"media.gmp-widevinecdm.autoupdate" = false;
			"media.eme.enabled" = true;
			"media.eme.encrypted-media-encryption-scheme.enabled" = true;
		};

		home.file."firefox-widevinecdm" = {
			enable = true;
			target = ".mozilla/firefox/${profile.path}/gmp-widevinecdm";
			source = pkgs.runCommandLocal "firefox-widevinecdm" { } ''
				out=$out/${self.package.version}
				mkdir -p $out
				ln -s ${self.package}/manifest.json $out/manifest.json
				ln -s ${self.package}/libwidevinecdm.so $out/libwidevinecdm.so
			'';
			recursive = true;
		};
	}) config.programs.firefox.profiles);
}
