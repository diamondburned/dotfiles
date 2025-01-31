{
  config,
  lib,
  pkgs,
  ...
}:

{
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      # opencl-headers
      # ocl-icd
      # khronos-ocl-icd-loader

      amdvlk
      rocmPackages_5.clr.icd
      rocmPackages_5.clr
      rocmPackages_5.rocm-runtime

      # rocmPackages.clr
      # rocmPackages.rpp-opencl
      # rocmPackages.rocm-runtime
    ];
  };

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages_5.clr}"
  ];

  environment.systemPackages = with pkgs; [
    lact
    clinfo
    amdgpu_top
    rocmPackages_5.rocminfo
  ];

  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];
}
