{ config, lib, pkgs, ... }:

with lib;
with builtins;

{
	imports = [
		./service.nix
	];

	services.diamondburned.nokbd = {
		enable = true;
		internalKeyboard.inputPath = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
		externalKeyboards = [
			{
				udevRules = {
					"SUBSYSTEMS" = "input";
					"ATTRS{name}" = "Air60 BT5.0 ";
					"ATTRS{phys}" = "70:a8:d3:23:22:5a";
				};
			}
		];
	};
}
