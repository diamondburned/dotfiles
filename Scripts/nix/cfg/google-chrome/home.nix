{ config, lib, pkgs, ... }:

let
	chromeArgs = [ "--gtk-version=4" ];
	chromePackage = pkgs.google-chrome;

	google-chrome = pkgs.runCommandLocal "google-chrome-wrapped" {} ''
		mkdir -p $out

		cp --no-preserve=ownership -Rs ${chromePackage}/. $out/
		chmod -R u+w $out

		${pkgs.tree}/bin/tree $out

		# Wrap the binary.
		rm $out/bin/google-chrome-stable
		cp ${pkgs.writeShellScript "google-chrome-launcher" ''
			exec ${chromePackage}/bin/google-chrome-stable ${lib.escapeShellArgs chromeArgs} "$@"
		''} $out/bin/google-chrome-stable

		# Patch the .desktop file.
		rm $out/share/applications/google-chrome.desktop
		sed -e 's|^Exec=.*|Exec='"$out"'/bin/google-chrome-stable|g' \
			${chromePackage}/share/applications/google-chrome.desktop \
			> $out/share/applications/google-chrome.desktop

		${pkgs.tree}/bin/tree $out
	'';
in

{
	home.packages = [
		google-chrome
	];
}
