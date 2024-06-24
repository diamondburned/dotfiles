{ config, lib, pkgs, ... }:

let
	css = lib.concatStringsSep "\n" (map builtins.readFile [
		./default.css
		# ./christmas.css
	]);

	theme = {
		name = "Colloid-Pink-Dark";
		package = pkgs.colloid-gtk-theme.override {
			themeVariants = [ "all" ];
			colorVariants = [ "standard" "light" "dark" ];
			sizeVariants  = [ "standard" "compact" ];
			tweaks = [
				"rimless"
				"normal"
				"float"
				# "black"
			];
		};
	};

	cursorTheme = {
		package = pkgs.catppuccin-cursors.mochaPink;
		name = "Catppuccin-Mocha-Pink-Cursors";
		size = 32;
	};

	env = {
		GTK_THEME = theme.name;
	};
in

{
	pam.sessionVariables = env;
	systemd.user.sessionVariables = env;

	gtk = {
		enable = true;
		font.name = "Sans";
		font.size = 11;

		theme = {
			name = theme.name;
			# Do not set theme.package here, as this will cause home-manager to insert the theme via
			# user.css which will not only mess up other application's themes but also override its theme.
			# This is a GTK issue as they have removed the ability to set the theme normally, so hacks
			# must be done to set the theme, and hacks are fragile.
		};

		iconTheme = {
			name = "Papirus-Dark";
			package = pkgs.papirus-icon-theme;
		};

		gtk3 = {
			extraCss = css;
			extraConfig = {
				# gtk-cursor-theme-name = cursorTheme.name;
				# gtk-cursor-theme-size = cursorTheme.size;
				# gtk-font-name = config.gtk.font.name + " " + config.gtk.font.size;
				# gtk-icon-theme-name = config.gtk.iconTheme.name;
				# gtk-theme-name = theme.name;
				# gtk-application-prefer-dark-theme = 1;
			};
		};

		gtk4 = {
			extraCss = css;
			extraConfig = {
				# gtk-cursor-theme-name = cursorTheme.name;
				# gtk-cursor-theme-size = cursorTheme.size;
				# gtk-font-name = config.gtk.font.name + " " + config.gtk.font.size;
				# gtk-icon-theme-name = config.gtk.iconTheme.name;
				# gtk-theme-name = theme.name;
			};
		};
	};

	home.pointerCursor = {
		inherit (cursorTheme) package name size;
		gtk.enable = true;
		x11.enable = true;
	};

	qt = {
		enable = true;
		platformTheme = "qtct";
		style = {
			name = "adwaita-dark";
			package = pkgs.adwaita-qt;
		};
	};

	home.packages = with pkgs; [
		# Themes
		papirus-icon-theme
		material-design-icons
		catppuccin-cursors.mochaPink
		catppuccin-cursors.macchiatoPink
		catppuccin-cursors.mochaFlamingo
		catppuccin-cursors.macchiatoFlamingo
		catppuccin-gtk
	] ++ [
		theme.package
	];
}
