{ config, lib, pkgs, ... }:

{
	imports = [
		<home-manager/nixos>
		<dotfiles/secrets>
		<dotfiles/cfg/fonts>
		<dotfiles/cfg/gnome>
		<dotfiles/cfg/tailscale>
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

	boot.extraModprobeConfig = ''
		options hid-apple swap_fn_leftctrl=1
	'';

	environment.systemPackages = with pkgs; [
		nix-search
	];

	services.openssh.enable = true;
	users.users.diamond.openssh.authorizedKeys.keyFiles = [
		<dotfiles/public_keys>
	];

	networking.firewall = {
		enable = true;
		allowedTCPPorts = [ ];
		allowedUDPPorts = [ ];
		# Allow ports for Tailscale.
		interfaces."tailscale0" = {
			allowedTCPPorts = [ 22 80 443 ];
			allowedUDPPorts = [ 22 80 443 ];
		};
	};
}
