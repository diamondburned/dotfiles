{ config, lib, pkgs, ... }:

let
	env = {
		GTK_THEME = config.gtk.theme.name;
	};

	css = pkgs.concatText "gtk.css" [
		./default.css
		# ./christmas.css
	];
in

{
	pam.sessionVariables = env;
	systemd.user.sessionVariables = env;

	gtk = {
		enable = true;
		font.name = "Nunito";
		font.size = 11;

		theme = {
			# name = "Colloid-Light";
			name = "Colloid-Pink-Dark";
			package =
				pkgs.colloid-gtk-theme.override {
					themeVariants = [ "all" ];
					colorVariants = [ "standard" "light" "dark" ];
					sizeVariants  = [ "standard" "compact" ];
					tweaks = [
						"rimless"
						"normal"
						# "black"
					];
				};
		};

		iconTheme = {
			# name = "Papirus-Light";
			name = "Papirus-Dark";
			package = pkgs.papirus-icon-theme;
		};

		cursorTheme = {
			name = "Catppuccin-Mocha-Pink-Cursors";
			size = 32;
		};

		gtk3 = {
			extraConfig = {
				gtk-application-prefer-dark-theme = 1;
				# gtk-application-prefer-dark-theme = 0;
			};
			extraCss = builtins.readFile css;
		};

		gtk4 = {
			extraCss = builtins.readFile css;
		};
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
		config.gtk.theme.package
	];
}
