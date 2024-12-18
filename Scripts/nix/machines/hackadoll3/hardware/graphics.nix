{
  config,
  lib,
  pkgs,
  ...
}:

let
  rocmEnv = pkgs.symlinkJoin {
    name = "rocm-combined";
    paths = with pkgs.rocmPackages; [
      rocblas
      hipblas
      clr
    ];
  };
in

{
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa
      libva
      libva-utils
      libvdpau-va-gl

      # AMD GPU stuff
      # amdvlk
      # rocmPackages.clr.icd
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
      libva-utils
    ];
  };

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];
}
