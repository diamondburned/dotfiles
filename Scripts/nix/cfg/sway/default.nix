{ config, lib, pkgs, ... }:

let utils = import ../../utils { inherit config lib pkgs; };

in {
	services.xserver.displayManager.gdm = {
		enable  = true;
		wayland = true;
	};

	programs.sway = {
		enable = true;
		extraSessionCommands = ''
			dbus-update-activation-environment --all --systemd
			systemctl --user import-environment
		'';
		wrapperFeatures = {
			gtk  = true;
			base = true;
		};
	};

	nix.binaryCachePublicKeys = [
		"nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
	];
	nix.binaryCaches = [
		"https://nixpkgs-wayland.cachix.org"
	];

	xdg.portal = {
		enable       = true;
		extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
		gtkUsePortal = true;
	};

	nixpkgs.overlays = [
		(import ../wayfire/overlay.nix)
	];

	# Extracted from Unstable's programs.xwayland.
	environment.pathsToLink = [
		"/share/X11"
		"/libexec" # polkit
	];

	environment.systemPackages = with pkgs; [
		# gappdash
	];
}
