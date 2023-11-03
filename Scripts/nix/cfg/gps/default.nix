{ config, lib, pkgs, ... }:

{
	services.geoclue2 = {
		enable = true;
		enableNmea = true;
	};

	environment.systemPackages = with pkgs; [
		gnss-share
	];
}
