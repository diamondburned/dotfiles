{ config, lib, pkgs, ... }:

with pkgs;
with config.boot.kernelPackages;

let
	displaylink = pkgs.displaylink.overrideAttrs (old: {
		src = pkgs.fetchurl {
			url = "https://www.synaptics.com/sites/default/files/exe_files/2023-08/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.8-EXE.zip";
			name = "displaylink.zip";
			hash = "sha256-IsVS6tRIyA2ejdSKhCu1ERhNB6dBgKx2vYndFE3dqBY=";
		};
	});
in

{
	boot.kernelModules = [ "evdi" ];
	boot.extraModulePackages = [ evdi ];
	services.udev.packages = [ displaylink ];

	services.xserver.displayManager.sessionCommands = ''
		${lib.getBin xorg.xrandr}/bin/xrandr --setprovideroutputsource 1 0
	'';

	systemd.services.dlm = {
		description = "DisplayLink Manager Service";
		after = [ "display-manager.service" ];
		conflicts = [ "getty@tty7.service" ];
		serviceConfig = {
			ExecStart = "${displaylink}/bin/DisplayLinkManager";
			Restart = "always";
			RestartSec = 5;
			LogsDirectory = "displaylink";
		};
	};
}
