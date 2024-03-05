{ config, pkgs, lib, ... }:

let
	drivers = {
		rtl8852au = {
			pname = "rtl8852au";
			version = "70bdde265b9ab002daf11d4bea1a42baa8da4325";
			sha256 = "sha256-6ARS7/0iKYajpMH+f+jWDxIkPY9ZixJkk864oKom4l4=";
		};
		rtl8188gu = {
			pname = "rtl8188gu";
			version = "699d0ccedf2e26c3f8fcca36cca45029585aa746";
			sha256 = "sha256-bcFGhtSQMX2M9h2zLSzoRT1UXYxiSH0WGLtC/JuPKTM=";
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
