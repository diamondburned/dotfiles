{ config, lib, pkgs, ... }:

let
	chromeArgs = [ "--gtk-version=4" ];
	chromePackage = pkgs.google-chrome;

	desktopFile = "google-chrome.desktop";
	binaryName = "google-chrome-stable";

	google-chrome = pkgs.runCommandLocal "google-chrome-wrapped" {} ''
		mkdir -p $out

		cp --no-preserve=ownership -Rs ${chromePackage}/. $out/
		chmod -R u+w $out

		${pkgs.tree}/bin/tree $out

		# Wrap the binary.
		rm $out/bin/${binaryName}
		cp ${pkgs.writeShellScript "google-chrome-launcher" ''
			exec ${chromePackage}/bin/${binaryName} ${lib.escapeShellArgs chromeArgs} "$@"
		''} $out/bin/${binaryName}

		# Patch the .desktop file.
		rm $out/share/applications/${desktopFile}
		sed -e 's|^Exec=[^ ]*|Exec='"$out"'/bin/${binaryName}|g' \
			${chromePackage}/share/applications/${desktopFile} \
			> $out/share/applications/${desktopFile}

		${pkgs.tree}/bin/tree $out
	'';
in

{
	home.packages = [
		google-chrome
	];
}
