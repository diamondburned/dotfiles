{ config, lib, pkgs, ... }:

{
	imports = [
		<home-manager/nixos>
		<dotfiles/secrets>
		<dotfiles/cfg/fonts>
		./home.nix
	];

	nixpkgs = {
		config.allowUnfree = true;
		overlays = [
			(import <dotfiles/overlays/overrides.nix>)
			(import <dotfiles/overlays/overrides-all.nix>)
			(import <dotfiles/overlays/packages.nix>)
		];
	};

	programs.dconf.enable = true;
	services.dbus.packages = with pkgs; [ dconf ];
}
