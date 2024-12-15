{ config, lib, pkgs, ... }:

{
	boot.kernelModules = [ "it87" "amd-pstate" ];

	boot.kernelParams = [
		# "acpi_enforce_resources=lax"
		# "amd_pstate=active"
	];

	environment.systemPackages = with pkgs; [
		lm_sensors
	];

	hardware.cpu.amd = {
		updateMicrocode = true;
		sev.enable = true;
	};

	services.hardware.openrgb = {
		enable = true;
		motherboard = "amd";
	};
}
