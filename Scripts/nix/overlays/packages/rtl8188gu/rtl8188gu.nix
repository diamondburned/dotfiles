{ config, pkgs, ... }:

let
	rtl8188gu = config.boot.kernelPackages.callPackage ./default.nix { };
in

{
	nixpkgs.overlays = [
		(self: super: {
			inherit rtl8188gu;
		})
	];
}
