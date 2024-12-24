{ config, lib, pkgs, ... }:

let
	cursorTheme = config.home-manager.users.diamond.home.pointerCursor;
	gtkTheme = config.home-manager.users.diamond.gtk.theme;
	gtkIconTheme = config.home-manager.users.diamond.gtk.iconTheme;
in

{
	services.xserver.displayManager.gdm = {
		enable  = lib.mkForce false;
		wayland = lib.mkForce false;
	};

	services.greetd.enable = true;

	programs.regreet = {
		enable = true;
		settings = {
			background.path = <dotfiles/background.jpg>;
			GTK = {
				cursor_theme_name = cursorTheme.name;
				application_prefer_dark_theme = true;
				font_name = "Sans 11";
				icon_theme_name = gtkIconTheme.name;
				theme_name = gtkTheme.name;
			};
		};
	};

	environment.systemPackages = [
		cursorTheme.package
		gtkTheme.package
		gtkIconTheme.package
	];
}
