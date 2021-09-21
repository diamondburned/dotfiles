{ pkgs, lib, config, ... }:

let ip = "192.168.1.7";

	schedule = {
		name        = "wyze-bulb";
		description = "Turn on the Wyze bulb everyday at 6PM";
		calendar    = "*-*-* 17:00";
		command     = "${pkgs.curl}/bin/curl -s http://${ip}/?m=1&d0=100";
	};

in {
	imports = [ (import ../../utils/schedule.nix schedule) ];
}
