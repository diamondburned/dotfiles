{ lib, pkgs, config, ... }:

{
	nixpkgs.config.packageOverrides = pkgs: rec {
		# transmission-web = pkgs.callPackage ./transmission-web/default.nix {};
	};

	imports = [
		./programs/vscode
		./programs/rhythmbox
	];
}
