{ config, lib, pkgs, ... }:

{
	services.udev.packages = [
		(pkgs.writeTextFile {
			# TODO: make this a proper derivative.
			name = "99-opentabletdriver.rules";
			text = builtins.readFile ./99-opentabletdriver.rules;
			destination = "/lib/udev/rules.d/99-opentabletdriver.rules";
	   	})
	];
}
