{ ... }:

{
  services.fstrim.enable = true;

  boot.initrd.luks.devices = {
    main = {
      device = "/dev/disk/by-uuid/43c71be8-6364-41e3-98df-026bf3f70dc9";
      bypassWorkqueues = true;
      crypttabExtraOpts = [
        "fido2-device=auto"
        "cipher=aes-xts-plain:sha256"
        "rd.luks.options=timeout=0"
        "rootflags=x-systemd.device-timeout=0"
      ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/main/root";
      fsType = "btrfs";
      options = [
        "discard=async"
        "ssd"
      ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/1AC8-4CF3";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 32768; # MB
      randomEncryption = {
        enable = true;
        cipher = "aes-xts-plain64";
        keySize = 256;
      };
    }
  ];

}
