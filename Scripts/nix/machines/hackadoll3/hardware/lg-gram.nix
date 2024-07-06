{ config, lib, pkgs, ... }:

{
	# LG Gram tweaks.
	# systemd.tmpfiles.rules = [
	# 	# https://01.org/linuxgraphics/gfx-docs/drm/admin-guide/laptops/lg-laptop.html
	# 	"w /sys/devices/platform/lg-laptop/battery_care_limit - - - - 80"
	# ];

	# Supposedly allow the fan to ramp up to 100%.
	# We can't change this after boot for some reason.
	# boot.initrd.postMountCommands = ''
	# 	echo 1 > /sys/devices/platform/lg-laptop/fan_mode
	# 	echo 80 > /sys/devices/platform/lg-laptop/battery_care_limit
	# '';

	# Do this instead for newer NixOS versions.
	boot.initrd.systemd.services."lg-gram-tweaks" = {
		description = "LG Gram tweaks";
		after = [ "systemd-modules-load.service" ];
		requires = [ "systemd-modules-load.service" ];
		wantedBy = [ "multi-user.target" ];
		script = ''
			# echo 1 > /sys/devices/platform/lg-laptop/fan_mode
			echo 80 > /sys/devices/platform/lg-laptop/battery_care_limit
		'';
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
		};
	};

	services.hardware.bolt.enable = true;

	# Do not suspend on lid close.
	# services.logind.lidSwitch = "ignore";

	hardware.cpu.intel.updateMicrocode = true;
}
