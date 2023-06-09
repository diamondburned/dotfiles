{ config, lib, pkgs, modulesPath, ... }:
# Nix just pulls modulesPath from its ass, apparently?

{
	imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

	boot.initrd.systemd.enable = true;
	boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
	boot.initrd.kernelModules = [ "dm-snapshot" ];
	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = [ ];

	boot.initrd.luks.devices = {
		main-luks = {
			device = "/dev/disk/by-uuid/8cdac4ef-f4ab-466c-a934-0129580f985f";
			bypassWorkqueues = true;
			crypttabExtraOpts = [ "fido2-device=auto" "cipher=aes-xts-plain:sha256" ];
		};
		home-luks = {
			device = "/dev/disk/by-uuid/8c741ec0-0ed3-4114-a9ab-e4abe5fc6071";
			bypassWorkqueues = true;
			crypttabExtraOpts = [ "fido2-device=auto" "cipher=aes-xts-plain:sha256" ];
		};
	};

	fileSystems."/" = {
		device	= "/dev/main/root";
		fsType	= "btrfs";
		options = [ "discard=async" "compress=lzo" "thread_pool=12" "ssd" ];
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
		{
			device = "/dev/disk/by-partuuid/44208e84-322c-4cac-ac72-30a747783df6";
			randomEncryption = {
				enable = true;
				cipher = "aes-xts-plain64";
				keySize = 256;
			};
		}
	];

	powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
