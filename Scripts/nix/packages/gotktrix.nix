{ pkgs }:

let src = pkgs.fetchFromGitHub {
	owner = "diamondburned";
	repo  = "gotktrix";
	rev   = "7fcac05a46f763c089d52cb313cedcb5516189fc";
	hash  = "sha256:1dl9sssfqx0dkxymh79mbczlrmpa70yqzk03dc36kr8gcrfnf2mn";
};

in pkgs.callPackage "${src}/.nix/package.nix" {
	gotktrixSrc  = src;
	vendorSha256 = "1drhpphcy2dz74zh9c9n2bq3qx6salyd8g5vwib7yz01hkyafi1m";
}
