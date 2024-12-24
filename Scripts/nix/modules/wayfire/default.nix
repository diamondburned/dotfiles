{ config, lib, pkgs, ... }: 

{
	nixpkgs.overlays = [
		(import ./overlay.nix)
	];

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
		];
	};

	xdg.portal = {
		enable = true;
		gtkUsePortal = true;
		# extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
	};

	environment.systemPackages = with pkgs; [
		wayfire
		polkit_gnome
		wlr-randr
	];

	home-manager.sharedModules = [
		{
			imports = [ ./home.nix ];
		}
	];
}
