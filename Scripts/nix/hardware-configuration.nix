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

	fileSystems."/" = {
		device = "/dev/disk/by-uuid/bc6d7c51-0f68-4270-bede-d824b5179482";
		fsType = "ext4";
	};

	fileSystems."/home" = {
		device = "/dev/disk/by-uuid/20521e43-1c9d-4072-9042-163da42d9f0e";
		fsType = "ext4";
	};

	fileSystems."/boot" = {
		device = "/dev/disk/by-uuid/1AC8-4CF3";
		fsType = "vfat";
	};

	swapDevices = [
		{ device = "/dev/disk/by-uuid/3c73d0ab-689f-4748-9cf0-a3eadeccac59"; }
	];

	nix.maxJobs = lib.mkDefault 8;
	powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
