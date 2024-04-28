{ stdenv, system, lib, buildGoModule, fetchFromGitHub, go_1_22 ? null }:

with lib;

let
	nixpkgs = fetchFromGitHub {
		owner = "NixOS";
		repo = "nixpkgs";
		rev = "77624624058066a324c1ff2ff464b53f43de4b0c"; # nixos-unstable
		sha256 = "sha256-kEd7Qw/LQcR4fktJHQGGpttPR3PbVNqORBUM7zFzunQ=";
	};

	go =
		if go_1_22 != null then
			go_1_22
		else
			lib.warn "Using go_1_22 from local caddy nixpkgs..."
			(import nixpkgs {
				inherit system;
			}).go_1_22;

	buildGoModule' = buildGoModule.override {
		inherit go;
	};
in

buildGoModule' {
	pname = "caddy";
	version = "local";

	src = ./.;
	subPackages = [ "." ];

	# modules = ./gomod2nix.toml;
	# allowGoReference = true;

	vendorHash = "sha256-aWIp5RMydSZ9gGDJK0VZJDI3VRA0ws+fXxNdnnsR0bQ=";

	meta = with lib; {
		homepage = https://caddyserver.com;
		description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
		license = licenses.asl20;
	};
}
