{
  disko.devices = {
    disk."hackadoll3" = {
      device = "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "hackadoll3-luks";
              settings = {
                allowDiscards = true;
              };
              content = {
                type = "lvm_pv";
                vg = "hackadoll3-pool";
              };
            };
          };
        };
      };
    };
    lvm_vg."hackadoll3-pool" = {
      type = "lvm_vg";
      lvs = {
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/root" = {
                mountpoint = "/";
                mountOptions = [
                  # "compress=zstd"
                  "noatime"
                ];
              };
              "/home" = {
                mountpoint = "/home";
                mountOptions = [
                  # "compress=zstd"
                  "noatime"
                ];
              };
              "/nix" = {
                mountpoint = "/nix";
                mountOptions = [
                  "compress=zstd:1"
                  "noatime"
                ];
              };
            };
          };
        };
        swap = {
          size = "32G";
          content = {
            type = "swap";
            resumeDevice = true;
            discardPolicy = "both";
          };
        };
      };
    };
  };
}
