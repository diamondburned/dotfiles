{ config, lib, pkgs, ... }:

{
	boot.initrd.kernelModules = [ "amdgpu" ];

	hardware.opengl = {
		enable = true;
		driSupport = true;
		driSupport32Bit = true;
		extraPackages = with pkgs; [
			mesa
			pocl
			libva
			libva-utils
			libvdpau-va-gl
			# AMD GPU stuff
			amdvlk
			rocmPackages.clr.icd
			# Intel GPU stuff
			# vaapiIntel
			# vaapi-intel-hybrid
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
