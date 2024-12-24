{ config, lib, pkgs, ... }:

let
	chromeArgs = [ "--gtk-version=4" ];

	chromePkgs = pkgs.extend (self: super: {
		widevine-cdm = super.callPackage ./widevine-cdm.nix { };
	});

	chrome = {
		package = chromePkgs.google-chrome;
		binaryName = "google-chrome-stable";
		desktopFile = "google-chrome.desktop";
	};

	chromium = {
		package = chromePkgs.chromium.override {
			enableWideVine = true;
		};
		binaryName = "chromium";
		desktopFile = "chromium-browser.desktop";
	};

	# package = chrome;
	package = chromium;

	wrapped = pkgs.runCommandLocal "google-chrome-wrapped" { } ''
		mkdir $out

		cp --no-preserve=ownership -rL ${package.package}/* $out/
		chmod -R u+w $out
		rm -r $out/bin/*

		echo BEFORE
		${pkgs.tree}/bin/tree $out

		# Wrap the binary.
		cp ${pkgs.writeShellScript "google-chrome-launcher" ''
			exec ${package.package}/bin/${package.binaryName} ${lib.escapeShellArgs chromeArgs} "$@"
		''} $out/bin/${package.binaryName}

		# Patch the .desktop file.
		rm $out/share/applications/${package.desktopFile}
		sed -e \
			"s|^Exec=[^ ]*|Exec=$out/bin/${package.binaryName}|g" \
			  ${package.package}/share/applications/${package.desktopFile} \
			> $out/share/applications/${package.desktopFile}

		echo AFTER
		${pkgs.tree}/bin/tree $out
	'';
in

{
	home.packages = [ wrapped ];
}
