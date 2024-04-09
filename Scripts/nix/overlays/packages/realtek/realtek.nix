{ config, pkgs, lib, ... }:

let
	drivers = {
		rtl8852au = {
			pname = "rtl8852au";
			src = <rtl8852au>;
		};
		rtl8188gu = {
			pname = "rtl8188gu";
			src = <rtl8188gu>;
		};
	};

	callRealtek = base:
		config.boot.kernelPackages.callPackage (import ./basepkg.nix base) { };

	allDrivers = lib.mapAttrs (name: attr: callRealtek attr) drivers;
in

{
	nixpkgs.overlays = [
		(self: super: allDrivers)
	];
}
