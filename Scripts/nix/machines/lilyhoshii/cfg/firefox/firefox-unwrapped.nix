{ pkgs }:

let
	lib = pkgs.lib;

	glibc = pkgs.callPackage ./glibc-patched.nix {};
  mkrpath = p: "${lib.makeSearchPathOutput "lib" "lib64" p}:${lib.makeLibraryPath p}";

	widevinecdm-aarch64 = pkgs.callPackage ./widevinecdm.nix {};

	firefox-unwrapped = pkgs.firefox-unwrapped;

	firefox-unwrapped-widevine = pkgs.runCommandLocal "firefox-unwrapped-widevine" {
		inherit (firefox-unwrapped) meta version passthru buildInputs;
		nativeBuildInputs = with pkgs; [ patchelf ];
	  PATCH_RPATH = mkrpath (with pkgs; [ gcc.cc glib nspr nss ]);
	} ''
		cp -r ${firefox-unwrapped}/. $out
		chmod -R u+w $out

		glibcPatch() {
			if [[ ! -f "$1" ]]; then
				echo "File $1 does not exist" >&2
				exit 1
			fi

			patchelf \
				--set-interpreter "$(cat ${glibc}/lib/ld-linux-aarch64.so.1)" \
				--add-rpath "$PATCH_RPATH" \
				"$1"
		}

		glibcPatch $out/lib/firefox/firefox-bin
		glibcPatch $out/lib/firefox/firefox
		glibcPatch $out/bin/firefox
		glibcPatch $out/bin/.firefox-wrapped

		mkdir -p $out/lib/firefox/gmp-widevinecdm/${widevinecdm-aarch64.widevinecdmVersion}
		ln -s \
			${widevinecdm-aarch64.widevinecdmManifest} \
			$out/lib/firefox/gmp-widevinecdm/${widevinecdm-aarch64.widevinecdmVersion}/manifest.json
		ln -s \
			${widevinecdm-aarch64}/WidevineCdm/_platform_specific/linux_arm64/libwidevinecdm.so \
			$out/lib/firefox/gmp-widevinecdm/${widevinecdm-aarch64.widevinecdmVersion}/libwidevinecdm.so
	'';
in
	firefox-unwrapped-widevine
