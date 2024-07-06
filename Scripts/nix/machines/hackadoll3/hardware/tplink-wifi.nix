{ config, lib, pkgs, ... }:

{
	# This needs to be manually stated, for some reason.
	boot.kernelModules = [
		"8852au"
		"8188gu"
	];

	boot.extraModulePackages = with pkgs; [
		pkgs.rtl8188gu
		pkgs.rtl8852au
	];

	# For certain USB WLAN/WWAN adapters.
	hardware.usb-modeswitch.enable = true;

	# Prevent the wrong Realtek driver from loading.
	boot.blacklistedKernelModules = [ "rtl8xxxu" ];
}
