{ stdenv, lib, fetchFromGitHub, buildGoModule, go }:

with lib;

buildGoModule rec {
	name = "xcaddy";
	version = "v0.1.9";

	src = fetchFromGitHub {
		owner = "caddyserver";
		repo  = "xcaddy";
		rev   = "v0.1.9";
		hash  = "sha256:19gsj3k9x5fb764hfiifp703jpl3daarch19l9f19zqc9b58nw93";
	};

	vendorHash = "sha256:1nilvjdmky1mf9vxrhy0322hl661y690ah3jg70pdlj9b0q4ilf8";

	meta = with lib; {
		homepage = https://github.com/caddyserver/xcaddy;
		description = "Build Caddy with plugins";
		license = licenses.asl20;
	};
}
