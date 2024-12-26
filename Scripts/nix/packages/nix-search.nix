{ fetchFromGitHub, lib, buildGoModule }:

buildGoModule rec {
	pname = "nix-search";
	version = "0.1.0";

	src = fetchFromGitHub {
		owner = "diamondburned";
		repo = "nix-search";
		rev = "v${version}";
		sha256 = "sha256-F6fxG7Sd1VOAxijzjqcAuJEl9Hq2hfOSnu8dcUnsxYY=";
	};

	vendorHash = "sha256-sxXbST9vKWisp5iDg8D3HZkGs3KEs+XV4hxLALkP8Fc=";
	subPackages = [ "cmd/nix-search" ];
}
