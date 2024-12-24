{ config, lib, pkgs, ... }:

{
	users.users.diamond = {
		extraGroups = [
			"wireshark"
		];
	};

	programs.wireshark = {
		enable  = true;
		package = pkgs.wireshark-qt;
	};
}
