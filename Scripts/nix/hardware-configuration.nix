{ config, lib, pkgs, modulesPath, ... }:
# Nix just pulls modulesPath from its ass, apparently?

{
	imports = [
		"${modulesPath}/installer/scan/not-detected.nix"
	];

	boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = [ ];

	boot.initrd.luks.devices = {
		home-luks.device = "/dev/disk/by-uuid/8c741ec0-0ed3-4114-a9ab-e4abe5fc6071";
	};

	fileSystems."/" = {
		device  = "/dev/disk/by-uuid/92a054fe-aea4-41f9-90fa-59b6a4143133";
		fsType  = "btrfs";
		options = [ "compress=lzo" ];
	};

	fileSystems."/home" = {
		device = "/dev/mapper/home-luks";
		fsType = "ext4";
	};

	fileSystems."/boot" = {
		device = "/dev/disk/by-uuid/1AC8-4CF3";
		fsType = "vfat";
	};

	swapDevices = [
		{ device = "/home/.swapfile"; size = 32 * 1024; }
	];

	powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
