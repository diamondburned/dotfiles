{ pkgs }:

let
	glibc = pkgs.glibc.overrideAttrs (old: {
		patches = old.patches ++ [ ./disable-GLIBC_ABI_DT_RELR-check.patch ];
		doCheck = false;
	});

	firefox = pkgs.wrapFirefox pkgs.firefox-unwrapped {};

	firefoxWidevine = pkgs.runCommandLocal "firefox-widevine" {
		inherit (pkgs.firefox-unwrapped) meta version passthru buildInputs;
		nativeBuildInputs = with pkgs; [ patchelf ];
	} ''
		cp -r ${firefox}/. $out
		chmod -R u+w $out

		glibcPatch() {
			patchelf \
				--set-interpreter "$(cat ${glibc}/lib/ld-linux-aarch64.so.1)" \
				--add-rpath ${glibc}/lib \
				"$1"
		}
		# glibcPatch $out/lib/firefox/firefox-bin
		# glibcPatch $out/lib/firefox/firefox
		glibcPatch $out/bin/.firefox-wrapped
	'';
in
	firefox
