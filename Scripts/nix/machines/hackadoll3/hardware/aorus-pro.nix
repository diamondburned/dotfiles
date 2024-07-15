{ config, lib, pkgs, ... }:

{
	boot.kernelModules = [ "it87" "amd-pstate" ];

	boot.kernelParams = [
		"acpi_enforce_resources=lax"
		"amd_pstate=active"
	];

	environment.systemPackages = with pkgs; [
		lm_sensors
	];

	# Fix fan sensors for the B450 I Aorus Pro WiFi.
	boot.extraModprobeConfig = ''
		options it87 ignore_resource_conflict=1 force_id=0x8628
	'';

	environment.etc."sensors.d/b450.conf".text = ''
		chip "it8628-isa-0a40"
		label temp1 "System 1"
		label temp2 "Chipset"
		label temp3 "CPU Socket"
		label temp4 "PCIEX16"
		label temp5 "VRM MOS"
		label temp6 "VSOC MOS"
		label in0 "CPU Vcore"
		label in1 "+3.3V"
		label in2 "+12V"
		label in3 "+5V"
		label in4 "CPU Vcore SOC"
		label in5 "CPU Vddp"
		label in6 "DRAM A/B"
		label fan1 "CPU_FAN"
		label fan2 "SYS_FAN1"
		label fan3 "SYS_FAN2"
		label fan4 "SYS_FAN3"
		label fan5 "CPU_OPT"
	'';
}
