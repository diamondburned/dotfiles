{ config, lib, pkgs, modulesPath, ... }:
# Nix just pulls modulesPath from its ass, apparently?

let
	crypttabOpts = [
		"fido2-device=auto"
		"cipher=aes-xts-plain:sha256"
		"rd.luks.options=timeout=0"
		"rootflags=x-systemd.device-timeout=0"
	];
in

{
	imports = [
		(modulesPath + "/installer/scan/not-detected.nix")
		./hardware/aorus-pro.nix
		./hardware/tertiary.nix
		./hardware/graphics.nix
	];

	boot.initrd.systemd.enable = true;
	boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
	boot.initrd.kernelModules = [ "dm-snapshot" ];
	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = [ ];

	boot.initrd.luks.devices = {
		main-luks = {
			device = "/dev/disk/by-uuid/8cdac4ef-f4ab-466c-a934-0129580f985f";
			bypassWorkqueues = true;
			crypttabExtraOpts = crypttabOpts;
		};
		home-luks = {
			device = "/dev/disk/by-uuid/8c741ec0-0ed3-4114-a9ab-e4abe5fc6071";
			bypassWorkqueues = true;
			crypttabExtraOpts = crypttabOpts;
		};
	};

	boot.loader.systemd-boot.enable = true;

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
			device = "/var/swapfile";
			size = 16 * 1024; # MB
			randomEncryption = {
				enable = true;
				cipher = "aes-xts-plain64";
				keySize = 256;
			};
		}
	];

	powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
