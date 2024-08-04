{ config, lib, pkgs, ... }:

{
	boot.initrd.kernelModules = [ "amdgpu" ];

	hardware.opengl = {
		enable = true;
		extraPackages = with pkgs; [
			mesa
			libva
			libva-utils
			libvdpau-va-gl

			# AMD GPU stuff
			amdvlk
			rocmPackages.clr.icd

			# Intel GPU stuff
			# vaapiIntel
			# vaapi-intel-hybrid

			# Intel CPU stuff
			intel-compute-runtime
		];
		extraPackages32 = with pkgs.pkgsi686Linux; [
			libva
			libva-utils
		];
	};

	systemd.tmpfiles.rules = [
		"L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
  ];
}
