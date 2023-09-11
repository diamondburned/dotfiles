{ config, lib, pkgs, ... }:

let
	profileName = "default";
	profilePath = "q1f740f8.default";

	widevinecdm-aarch64 = pkgs.callPackage ./widevinecdm.nix {};

	widevinecdm-manifest = pkgs.writeText "widevinecdm-manifest.json"
		(builtins.toJSON {
			name = "WidevineCdm";
			description = "Widevine Content Decryption Module";
			version = widevinecdm-aarch64.widevinecdmVersion;
			"x-cdm-codecs" = "vp8,vp9.0,avc1,av01";
			"x-cdm-host-versions" = "4.10";
			"x-cdm-interface-versions" = "4.10";
			"x-cdm-module-versions" = "4.10";
			"x-cdm-persistent-license-support" = true;
		});
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

# buildCC = pkgs: glibc: with pkgs;
# let
#   cc = wrapCCWith {
#     cc = gcc-unwrapped;
#     libc = glibc;
#     bintools = binutils.override {
#       libc = glibc;
#     };
#   };
# in
# (overrideCC stdenv cc).cc.cc;
	programs.firefox.package = lib.mkForce (import ./package.nix { inherit pkgs; });

	home.file."firefox-widevinecdm" = {
		enable = true;
		target = ".mozilla/firefox/${profilePath}/gmp-widevinecdm";
		source = pkgs.runCommandLocal "firefox-widevinecdm" {} ''
			d=$out/${widevinecdm-aarch64.widevinecdmVersion}
			mkdir -p $d
			ln -s ${widevinecdm-manifest} $d/manifest.json
			ln -s ${widevinecdm-aarch64}/WidevineCdm/_platform_specific/linux_arm64/libwidevinecdm.so $d/libwidevinecdm.so
		'';
		recursive = true;
	};
}
