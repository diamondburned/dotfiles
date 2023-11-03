{ lib, pkgs, ... }:

let
	src = pkgs.fetchurl {
		src = "https://github.com/diamondburned/bulbremote/releases/download/v0.0.2/dist.tar.gz";
		sha256 = "1jyd7hv2ivba4bjx106dmcmgbdy74lcn664l9hb2vy5gpnf0x1y3";
	};
in

{
	services.diamondburned.caddy.sites."bulb.hackadoll3.ts.libdb.so" = '''';
}
