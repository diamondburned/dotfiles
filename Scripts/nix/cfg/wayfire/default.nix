{ config, lib, pkgs, ... }: 

{
	programs.wayfire = {
		enable = true;
		plugins = with pkgs.wayfirePlugins; [
			wcm
			wf-shell
			wayfire-plugins-extra
		];
	};

	services.displayManager = {
		enable = true;
		sessionPackages = with pkgs; [
			wayfire
			wayfire-session
		];
	};

	services.xserver.displayManager.gdm = {
		enable  = true;
		wayland = true;
	};

	xdg.portal = {
		enable = true;
		gtkUsePortal = true;
		# extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
	};

	environment.systemPackages = with pkgs; [
		wayfire
		wayfire-session
		polkit_gnome
		wlr-randr
	];

	home-manager.sharedModules = [
		{
			imports = [ ./home.nix ];
		}
	];
}
