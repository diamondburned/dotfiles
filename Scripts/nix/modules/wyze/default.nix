{ pkgs, lib, config, ... }:

let ip = "10.0.0.248";

	schedule = {
		name        = "wyze-bulb";
		description = "Turn on the Wyze bulb everyday at 4:30PM";
		calendar    = "*-*-* 16:30";
		command     = "${pkgs.curl}/bin/curl -s 'http://${ip}/?m=1&d0=100'";
	};

in {
	imports = [ (import ../../utils/schedule.nix schedule) ];
}
