{ stdenv, lib, buildGoApplication }:

with lib;

buildGoApplication {
	pname = "caddy";
	version = "v2";
	src = ./.;

	modules = ./gomod2nix.toml;
	subPackages = [ "." ];

	doCheck = false;

	GOSUMDB = "off";

	meta = with lib; {
		homepage = https://caddyserver.com;
		description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
		license = licenses.asl20;
	};
}
