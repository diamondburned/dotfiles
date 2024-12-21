{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
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
    ./hardware/asus-tuf.nix
    ./hardware/tertiary.nix
    ./hardware/graphics.nix
    ./hardware/disks.nix
  ];

  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
