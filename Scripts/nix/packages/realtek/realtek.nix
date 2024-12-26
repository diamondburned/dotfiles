{ config, pkgs, lib, ... }:

let
	sources = import <dotfiles/nix/sources.nix> { inherit pkgs; };

	drivers = {
		rtl8852au = {
			name = "rtl8852au";
			src = sources.rtl8852au;
		};
		rtl8188gu = {
			name = "rtl8188gu";
			src = sources.rtl8188gu;
		};
	};

	callRealtek = base:
		(config.boot.kernelPackages.callPackage (import ./basepkg.nix base) { }).overrideAttrs (old: {
		});

	allDrivers = lib.mapAttrs (name: attr: callRealtek attr) drivers;
in

{
	nixpkgs.overlays = [
		(self: super: allDrivers)
	];
}
