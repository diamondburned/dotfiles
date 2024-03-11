{ config, lib, pkgs, ... }:

let
	chromeArgs = [ "--gtk-version=4" ];
	chromePackage = pkgs.google-chrome;

	google-chrome = pkgs.runCommandLocal "google-chrome-wrapped" {} ''
		mkdir -p $out/bin

		ln -s ${chromePackage}/share $out/share
		ln -s ${pkgs.writeShellScript "google-chrome-launcher" ''
			exec ${chromePackage}/bin/google-chrome-stable ${lib.escapeShellArgs chromeArgs} "$@"
		''} $out/bin/google-chrome-stable
	'';
in

{
	home.packages = [
		google-chrome
	];
}
