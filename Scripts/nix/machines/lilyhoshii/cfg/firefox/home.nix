{ config, lib, pkgs, ... }:

let
	profileName = "default";
	profilePath = "q1f740f8.default";

	unstable = import <unstable> {
		config = { allowUnfree = true; };
	};

	widevinecdm-aarch64 = unstable.callPackage ./widevinecdm.nix {};
in

{
	programs.firefox.profiles.${profileName} = {
		settings = {
			"media.gmp-widevinecdm.version" = widevinecdm-aarch64.widevinecdmVersion;
			"media.gmp-widevinecdm.visible" = true;
			"media.gmp-widevinecdm.enabled" = true;
			"media.gmp-widevinecdm.autoupdate" = false;
			"media.eme.enabled" = true;
			"media.eme.encrypted-media-encryption-scheme.enabled" = true;
		};
	};

	# TODO: fix crash:
	#  [GFX1-]: glxtest: ManageChildProcess failed
	#  [GFX1-]: No GPUs detected via PCI
	programs.firefox.package = lib.mkForce
		(pkgs.wrapFirefox
			(import ./firefox-unwrapped.nix { pkgs = unstable; })
			{});
	# programs.firefox.package = lib.mkForce
	# 	(pkgs.wrapFirefox unstable.firefox-unwrapped {});

	# home.file."firefox-widevinecdm" = {
	# 	enable = true;
	# 	target = ".mozilla/firefox/${profilePath}/gmp-widevinecdm";
	# 	source = pkgs.runCommandLocal "firefox-widevinecdm" {} ''
	# 		d=$out/${widevinecdm-aarch64.widevinecdmVersion}
	# 		mkdir -p $d
	# 		ln -s ${widevinecdm-aarch64.widevinecdmManifest} $d/manifest.json
	# 		ln -s ${widevinecdm-aarch64}/WidevineCdm/_platform_specific/linux_arm64/libwidevinecdm.so $d/libwidevinecdm.so
	# 	'';
	# 	recursive = true;
	# };
}
