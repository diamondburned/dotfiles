{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
	widevinecdmPackage = pkgs.callPackage ./asahi-widevinecdm-package.nix { };
in

{
	options.programs.firefox.profiles = mkOption {
		type = types.attrsOf (types.submodule ({ config, ... }: {
			options.enableAsahiWidevine = mkEnableOption "Enable Widevine DRM support for this profile";
			config.settings = mkIf config.enableAsahiWidevine {
				"media.gmp-widevinecdm.version" = widevinecdmPackage.version;
				"media.gmp-widevinecdm.visible" = true;
				"media.gmp-widevinecdm.enabled" = true;
				"media.gmp-widevinecdm.autoupdate" = false;
				"media.eme.enabled" = true;
				"media.eme.encrypted-media-encryption-scheme.enabled" = true;
			};
		}));
	};

	# config = mkMerge (mapAttrsToList
	# 	(_: profile: (mkIf profile.enableAsahiWidevine {
	# 		home.file."firefox-widevinecdm-${profile.name}" = {
	# 			enable = true;
	# 			target = ".mozilla/firefox/${profile.path}/gmp-widevinecdm";
	# 			source = pkgs.runCommandLocal "firefox-widevinecdm" { } ''
	# 				out=$out/${widevinecdmPackage.version}
	# 				mkdir -p $out
	# 				ln -s ${widevinecdmPackage}/manifest.json $out/manifest.json
	# 				ln -s ${widevinecdmPackage}/libwidevinecdm.so $out/libwidevinecdm.so
	# 			'';
	# 			recursive = true;
	# 		};
	# 	}))
	# 	config.programs.firefox.profiles
	# );
}
