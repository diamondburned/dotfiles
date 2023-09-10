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
		font.name = "Sans";
		font.size = 11;

		theme = {
			name = "Colloid-Pink-Dark-Compact";
			package =
				# let orchis-theme = pkgs.orchis-theme.overrideAttrs (old: rec {
				# 	version = "2023-01-25";
				# 	src = pkgs.fetchFromGitHub {
				# 	    repo = "Orchis-theme";
				# 	    owner = "vinceliuice";
				# 	    rev = version;
				# 	    sha256 = "sha256:0rlvqzlfabvayp9p2ihw4jk445ahhrgv6zc5n47sr5w6hbb082ny";
				# 	};
				# });
				# let orchis-theme = pkgs.nixpkgs_unstable_real.orchis-theme.overrideAttrs (old: {
				# 	patches = (old.patches or []) ++ [
				# 		./overlays/patches/Orchis-theme-middark.patch
				# 	];
				# });
				# in orchis-theme.override {
				# 	tweaks = [ "compact" ];
				# 	border-radius = 6;
				# };
				pkgs.colloid-gtk-theme.override {
					themeVariants = [ "all" ];
					colorVariants = [ "standard" "light" "dark" ];
					sizeVariants = [ "compact" ];
					tweaks = [ "normal" "black" ];
				};
		};

		iconTheme = {
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
		materia-theme
		material-design-icons
		catppuccin-cursors.mochaPink
		catppuccin-cursors.macchiatoPink
		catppuccin-cursors.mochaFlamingo
		catppuccin-cursors.macchiatoFlamingo
		catppuccin-gtk
	];
}
