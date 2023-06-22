{ config, lib, pkgs, ... }:

{
	imports = [
		(import <lanzaboote>).nixosModules.lanzaboote
	];

	services.fwupd.enable = true;

	boot = {
		bootspec.enable = true;
		loader.systemd-boot.enable = lib.mkForce false;
		lanzaboote = {
			enable = true;
			pkiBundle = "/etc/secureboot";
		};
	};

	environment.systemPackages = with pkgs; [
		sbctl
	];
}
