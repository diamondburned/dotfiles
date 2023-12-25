{ config, lib, pkgs, ... }:

let
	env = {
		GTK_THEME = config.gtk.theme.name;
	};
in

{
	xdg.enable = true;
	xdg.configFile = {
		"gtk-3.0/gtk.css".source = <dotfiles/cfg/gtk.css>;
		"gtk-4.0/gtk.css".source = <dotfiles/cfg/gtk.css>;
	};

	pam.sessionVariables = env;
	systemd.user.sessionVariables = env;

	gtk = {
		enable = true;
		font.name = "Nunito";
		font.size = 11;

		theme = {
			# name = "Colloid-Pink-Dark-Compact";
			name = "Colloid-Light";
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
			# name = "Papirus-Dark";
			name = "Papirus-Light";
			package = pkgs.papirus-icon-theme;
		};

		cursorTheme = {
			name = "Catppuccin-Mocha-Pink-Cursors";
			size = 32;
		};

		gtk3 = {
			extraConfig = {
				# gtk-application-prefer-dark-theme = 1;
			};
			# extraCss = builtins.readFile ./cfg/gtk.css;
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
	];
}
