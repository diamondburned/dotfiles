{ config, lib, pkgs, ... }:

let
	flathub = package: { appId = package; origin = "flathub"; };
	flathubBeta = package: { appId = package; origin = "flathub-beta"; };
in

{
	services.flatpak = {
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
			(flathubBeta "org.gimp.GIMP")
		];
		update.auto = {
		  enable = true;
		  onCalendar = "weekly";
		};
	};
}
