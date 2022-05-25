{ config, lib, pkgs, ... }: 

{
	services.xserver.displayManager = {
		gdm = {
			enable  = true;
			wayland = true;
		};
		sessionPackages = with pkgs; [
			wayfire-session
		];
	};

	nix.binaryCachePublicKeys = [
		"nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
	];
	nix.binaryCaches = [
		"https://nixpkgs-wayland.cachix.org"
	];

	xdg.portal = {
		enable = true;
		extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
		gtkUsePortal = false;
	};

	nixpkgs.overlays = [ (import ./overlay.nix) ];

	# Extracted from Unstable's programs.xwayland.
	environment.pathsToLink = [
		"/share/X11"
		"/libexec" # polkit
	];

	environment.systemPackages = with pkgs; [
		# labwc
		# labwc-session
		wayfire
		wayfire-session
		polkit_gnome
	];

	# services.xserver.enable  = true;
}
