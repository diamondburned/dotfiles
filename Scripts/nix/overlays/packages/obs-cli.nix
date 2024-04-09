{ pkgs }:

pkgs.buildGoModule {
	pname = "obs-cli";
	version = "v0.5.0";

	src = pkgs.fetchFromGitHub {
		owner = "muesli";
		repo  = "obs-cli";
		rev   = "v0.5.0";
		hash  = "sha256:19wv493m9hckgrq51imavgg3x5s3jm71h26frvsg8gxjypwd5n72";
	};

	vendorHash = "03r2asykqllds1kwrddwcfbvb8q494l7x0w6pxcskkbvgyln8sj4";
}
