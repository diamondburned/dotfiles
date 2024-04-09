{ config, pkgs, lib, ... }:

let
	drivers = {
		rtl8852au = {
			name = "rtl8852au";
			src = <rtl8852au>;
		};
		rtl8188gu = {
			name = "rtl8188gu";
			src = <rtl8188gu>;
		};
	};

	callRealtek = base:
		(config.boot.kernelPackages.callPackage (import ./basepkg.nix base) { }).overrideAttrs (old: {
			unpackPhase = ''
				echo "Copying from $src to ."
				set -x
				cp --no-preserve=ownership -r "$src/"* .
				chmod -R u+rw .
				set +x
			'';
		});

	allDrivers = lib.mapAttrs (name: attr: callRealtek attr) drivers;
in

{
	nixpkgs.overlays = [
		(self: super: allDrivers)
	];
}
