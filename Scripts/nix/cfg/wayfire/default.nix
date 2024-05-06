{ config, lib, pkgs, ... }: 

{
	programs.wayfire = {
		enable = true;
		plugins = with pkgs.wayfirePlugins; [
			wcm
			wayfire-plugins-extra
		];
	};

	services.xserver.displayManager = {
		gdm = {
			enable  = true;
			wayland = true;
		};
		# sessionPackages = with pkgs; [
		# 	wayfire-session
		# ];
	};

	xdg.portal = {
		enable = true;
		extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
		gtkUsePortal = false;
	};

	# Extracted from Unstable's programs.xwayland.
	environment.pathsToLink = [
		"/share/X11"
		"/libexec" # polkit
	];

	environment.systemPackages = with pkgs; [
		# wayfire
		# wayfire-session
		polkit_gnome
		wlr-randr
	];

	home-manager.sharedModules = [
		{
			imports = [ ./home.nix ];
		}
	];
}
