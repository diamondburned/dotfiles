{ lib, pkgs, config, ... }:

{
	nixpkgs.overlays = [
		(import ./overlay.nix)
		(import <polymc>).overlay
		(self: super: {
			transmission-web = super.callPackage ./packages/transmission-web {};
			audacious-3-5 = super.callPackage ./packages/audacious-3-5 {};
			tagtool  = super.callPackage ./packages/tagtool.nix {};
			ymuse    = super.callPackage ./packages/ymuse {};
			srain    = super.callPackage ./packages/srain {};
			caddy    = super.callPackage ./packages/caddy {};
			xcaddy   = super.callPackage ./packages/xcaddy {};
			caddyv1  = super.callPakcage ./packages/caddyv1 {};
			vkmark   = super.callPackage ./packages/vkmark {};
			aqours   = super.callPackage ./packages/aqours {};
			ghproxy  = super.callPackage ./packages/ghproxy {};
			openmoji = super.callPackage ./packages/openmoji {};
			blobmoji = super.callPackage ./packages/blobmoji {};
			drone-ci = super.callPackage ./packages/drone-ci {};
			gappdash = super.callPackage ./packages/gappdash {};
			osu-wine = super.callPackage ./packages/osu-wine {};
			osu-wineprefix = super.callPackage ./packages/osu-wineprefix {};
			intiface-cli = super.callPackage ./packages/intiface-cli {};
			catnip-gtk = super.callPackage ./packages/catnip-gtk {};
			passwordsafe = super.callPackage ./packages/gnome-passwordsafe {};
			google-chrome-ozone = super.callPackage ./packages/google-chrome-ozone {};
			lightdm-elephant-greeter = super.callPackage ./packages/lightdm-elephant-greeter;
			rhythmbox-alternative-toolbar = pkgs.callPackage ./packages/rhythmbox-alternative-toolbar {};
			# gnomeExtensions = super.gnomeExtensions // {
			# 	easyscreencast = super.callPackage ./packages/gnome-extensions/easyscreencast {};
			# };
		})
	];

	imports = [
		./packages/transmission-web/service.nix
		./packages/nixie/service.nix
		./packages/butterfly/service.nix
		./packages/caddy/caddy.nix
		./packages/xcaddy/xcaddy.nix
		./packages/caddyv1/caddy.nix
		./packages/ghproxy/ghproxy.nix
		./packages/drone-ci/drone-ci.nix
	];
}
