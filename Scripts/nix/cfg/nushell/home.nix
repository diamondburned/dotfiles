{ config, lib, pkgs, ... }:

{
	programs.nushell = {
		enable = true;
		configFile.source = ./config.nu;
	};
}