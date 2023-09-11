{ pkgs }:

let
	glibc = pkgs.glibc.overrideAttrs (self: super: {
		name = "glibc-widevine-${super.version}";
		patches = super.patches ++ [ ./disable-GLIBC_ABI_DT_RELR-check.patch ];
		doCheck = false;
	});

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

	firefox-unwrapped = pkgs.firefox-unwrapped;

	firefox-unwrapped-widevine = pkgs.runCommandLocal "firefox-unwrapped-widevine" {
		inherit (pkgs.firefox-unwrapped) meta version passthru buildInputs;
		nativeBuildInputs = with pkgs; [ patchelf ];
	} ''
		cp -r ${firefox-unwrapped}/. $out
		chmod -R u+w $out

		glibcPatch() {
			if [[ ! -f "$1" ]]; then
				echo "File $1 does not exist" >&2
				exit 1
			fi

			patchelf --set-interpreter "$(cat ${glibc}/lib/ld-linux-aarch64.so.1)" "$1"
		}

		glibcPatch $out/lib/firefox/firefox-bin
		glibcPatch $out/lib/firefox/firefox
		glibcPatch $out/bin/firefox
		glibcPatch $out/bin/.firefox-wrapped

		# This is also done in home-manager.
		# I'm doing this here just in case, but Firefox reports it as installed.

		mkdir -p $out/lib/firefox/gmp-widevinecdm/${widevinecdm-aarch64.widevinecdmVersion}
		ln -s \
			${widevinecdm-manifest} \
			$out/lib/firefox/gmp-widevinecdm/${widevinecdm-aarch64.widevinecdmVersion}/manifest.json
		ln -s \
			${widevinecdm-aarch64}/WidevineCdm/_platform_specific/linux_arm64/libwidevinecdm.so \
			$out/lib/firefox/gmp-widevinecdm/${widevinecdm-aarch64.widevinecdmVersion}/libwidevinecdm.so
	'';
in
	pkgs.wrapFirefox firefox-unwrapped-widevine {}
