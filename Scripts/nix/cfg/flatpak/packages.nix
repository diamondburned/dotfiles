{ config, lib, pkgs, ... }:

let
	flathub = package: { appId = package; origin = "flathub"; };
	flathubBeta = package: { appId = package; origin = "flathub-beta"; };
in

{
	services.flatpak = {
		enable = true;
		remotes = lib.mkOptionDefault [
			{
				name = "flathub-beta";
				location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
			}
		];
		packages = [
			(flathub "com.viber.Viber")
			(flathub "com.boxy_svg.BoxySVG")
			(flathub "io.github.Foldex.AdwSteamGtk")
			(flathub "org.telegram.desktop")
			(flathub "re.sonny.Workbench")
			(flathub "app.drey.Biblioteca")
			(flathubBeta "org.gimp.GIMP")
		];
		update.auto = {
		  enable = true;
		  onCalendar = "weekly";
		};
		overrides = {
			global = {
				Context.filesystems = [
					# Expose current system fonts.
					"/run/current-system/sw/share/X11/fonts:ro"
					# Expose user fonts.
					"${config.home.homeDirectory}/.fonts:ro"
					"${config.home.homeDirectory}/.local/share/fonts:ro"
					# Expose user icons.
					"${config.home.homeDirectory}/.icons:ro"
					"${config.home.homeDirectory}/.local/share/icons:ro"
					# The system fonts are actually stored in /nix/store, so we expose
					# all of this too.
					"/nix/store:ro"
				];
			};
		};
	};
}
