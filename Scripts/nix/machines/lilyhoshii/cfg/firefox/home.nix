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
	programs.firefox.package =
		let
			glibc = pkgs.glibc.overrideAttrs (old: {
				patches = old.patches ++ [ ./disable-GLIBC_ABI_DT_RELR-check.patch ];
				doCheck = false;
			});
			firefox-unwrapped = pkgs.runCommandLocal "firefox-unwrapped-widevine" {
				inherit (pkgs.firefox-unwrapped) meta version passthru buildInputs;
				nativeBuildInputs = with pkgs; [ patchelf ];
			} ''
				cp -r ${pkgs.firefox-unwrapped}/. $out
				chmod -R u+w $out

				glibcPatch() {
					patchelf \
						--set-interpreter "$(cat ${glibc}/lib/ld-linux-aarch64.so.1)" \
						--set-rpath ${glibc}/lib \
						"$1"
					echo -n "FUCK YOU FUCK YOU FUCK YOU IOBHRUOH" >> "$1"
				}
				glibcPatch $out/lib/firefox/firefox-bin
				glibcPatch $out/lib/firefox/firefox
				glibcPatch $out/bin/firefox
			'';
		in
			lib.mkForce (pkgs.wrapFirefox firefox-unwrapped {});

	home.file."firefox-widevinecdm" = {
		enable = true;
		target = ".mozilla/firefox/${profilePath}/gmp-widevinecdm";
		source = pkgs.runCommandLocal "firefox-widevinecdm" {
			widevinecdm = widevinecdm-aarch64;
			nativeBuildInputs = with pkgs; [ jq ];
		} ''
			d=$out/${widevinecdm-aarch64.widevinecdmVersion}
			mkdir -p $d
			install -Dm644 ${widevinecdm-manifest} $d/manifest.json
			install -Dm755 ${widevinecdm-aarch64}/WidevineCdm/_platform_specific/linux_arm64/libwidevinecdm.so $d/libwidevinecdm.so
		'';
		recursive = true;
	};
}
