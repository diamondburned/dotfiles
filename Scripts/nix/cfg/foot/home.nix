{ config, lib, pkgs, ... }:

{
	programs.foot = {
		enable = true;
		server.enable = true;
	};

	xdg = {
		enable = true;
		configFile."foot/foot.ini".source = ./foot.ini;
	};
}
