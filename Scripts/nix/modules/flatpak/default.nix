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

	# https://nixos.wiki/wiki/Fonts#Flatpak_applications_can.27t_find_system_fonts
	fonts.fontDir.enable = true;

	home-manager.sharedModules = [
		{
			imports = [
				"${nix-flatpak}/modules/home-manager.nix"
			];
		}
	];
}
