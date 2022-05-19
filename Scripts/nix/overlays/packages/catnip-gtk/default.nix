{ pkgs, lib }:

let src = pkgs.fetchFromGitHub {
		owner  = "diamondburned";
		repo   = "catnip-gtk";
		rev    = "92350c410e39595703e0191314d15ea3f4975806";
		sha256 = "0z09iqq1m4hdpj5ddzvd44ky8ixj320bzsy7fiwpcazb2v604shf";
	};

	shell = import "${src}/shell.nix" {
		unstable = pkgs;
	};

in pkgs.buildGoModule {
	name = "catnip-gtk";
	version = "92350c4";

	inherit src;

	buildInputs = shell.buildInputs;

	nativeBuildInputs = with pkgs; [
		pkgconfig
	];

	vendorSha256 = "18bpxzwpplz9xbgjwz1n704fcqgw3fplqsjzc587ibk25crv7w19";
}
