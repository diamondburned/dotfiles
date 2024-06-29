{ config, lib, pkgs, ... }:

let
	sources = import <dotfiles/nix/sources.nix> { inherit pkgs; };
	nix-flatpak = sources.nix-flatpak;
in

{
	imports = [
		"${nix-flatpak}/modules/nixos.nix"
	];

	services.flatpak.enable = true;

	home-manager.sharedModules = [
		{
			imports = [
				"${nix-flatpak}/modules/home-manager.nix"
			];
		}
	];
}
