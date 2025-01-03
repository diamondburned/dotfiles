{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./hardware/asus-tuf.nix
    ./hardware/tertiary.nix
    ./hardware/graphics.nix
    ./hardware/scarlett.nix
    ./hardware/disks.nix
  ];

  nix = {
    settings.max-jobs = lib.mkForce 2;
    settings.cores = lib.mkForce 6;
  };

  boot = {
    loader = {
      systemd-boot = {
        # systemd-boot is not used when cfg/secureboot is imported.
        enable = lib.mkDefault true;
        configurationLimit = 25;
      };
      efi.canTouchEfiVariables = true;
    };

    # This needs to be manually stated, for some reason.
    kernelModules = [
      "i2c-dev"
      "ddcci"
      "ddcci_backlight"
    ];

    kernelParams = [
      "mitigations=off"
    ];

    kernel.sysctl = {
      # Anon-patch
      "vm.unevictable_anon_kbytes_low" = 65536;
      "vm.unevictable_anon_kbytes_min" = 32768;
      # Regular-patch
      "vm.unevictable_file_kbytes_low" = 262144;
      "vm.unevictable_file_kbytes_min" = 131072;
    };

    extraModulePackages =
      with pkgs;
      with config.boot.kernelPackages;
      [
        ddcci-driver
      ];

    initrd = {
      systemd.enable = true;
      kernelModules = [
        "dm-snapshot"
      ];
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "cryptd"
        "rtsx_pci_sdmmc"
      ];
      luks.cryptoModules = [
        "aes"
        "aes_generic"
        "cryptd"
        "blowfish"
        "twofish"
        "serpent"
        "cbc"
        "xts"
        "lrw"
        "sha1"
        "sha256"
        "sha512"
        "af_alg"
        "algif_skcipher"
      ];
    };

    kernel.sysctl = {
      "vm.swappiness" = lib.mkForce 65;
    };
  };

  hardware = {
    i2c.enable = true;

    bluetooth = {
      enable = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          FastConnectable = true;
        };
      };
    };

    steam-hardware.enable = true;

    opentabletdriver.enable = false;
  };

  services = {
    ddccontrol.enable = true;
    blueman.enable = true;
    power-profiles-daemon.enable = true;
  };

  security.rtkit.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
