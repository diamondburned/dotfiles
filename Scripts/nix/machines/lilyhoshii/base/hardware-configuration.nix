# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "usb_storage" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices = {
    main = {
      device = "/dev/disk/by-uuid/aae5595b-9597-4259-ac94-be73694d2712";
      bypassWorkqueues = true;
      crypttabExtraOpts = {
        # TODO
      };
    };
  };

  fileSystems."/" =
    { device = "/dev/main/root";
      fsType = "btrfs";
      options = [ "discard=async" "compress=lzo" "thread_pool=2" "ssd" ];
    };

  swapDevices =
    [ { device = "/dev/main/swap"; 
        randomEncryption = {
          enable = true;
          cipher = "aes-xts-plain64";
          keySize = 256;
        };
       }
    ];

  hardware.asahi.addEdgeKernelConfig = true;
  hardware.asahi.useExperimentalGPUDriver = true;

  boot.kernelPackages =
    let
      kernelPackages' = pkgs.linux-asahi.override {
        _kernelPatches = config.boot.kernelPatches;
        _4KBuild = config.hardware.asahi.use4KPages;
        withRust = config.hardware.asahi.withRust;
      };
      kernel' = kernelPackages'.kernel;
      # kernel' = kernelPackages.kernel.override {
      #   inherit (import <nixpkgs_older_rust> {})
      #     rustc
      #     rustPlatform
      #     rust-bindgen;
      # };
      kernel = kernel'.overrideAttrs (old: {
        src = builtins.storePath <asahilinux>;
        version = "asahi-6.6-latest";
        unpackPhase = ''
          cp -r $(realpath $src)/. .
          chmod -R u+w .
        '';
      });
    in
      lib.mkForce (pkgs.linuxPackagesFor kernel);

  # boot.kernelPackages = lib.mkForce
  #   (pkgs.callPackage ./asahi-kernel.nix {
  #     _kernelPatches = config.boot.kernelPatches;
  #     _4KBuild = config.hardware.asahi.use4KPages;
  #     withRust = config.hardware.asahi.withRust;
  #   });

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
