{ pkgs }:

let src = pkgs.fetchFromGitHub {
	owner = "diamondburned";
	repo  = "gotktrix";
	rev   = "c1098ba9a98852083109a21c3100369ad19008ba";
	hash  = "sha256:1ly0jgrixxb5mdsgyag4a2lfqz1dbas57i7gi2zakc8m7i95nqhd";
};

in pkgs.callPackage "${src}/.nix/package.nix" {
	gotktrixSrc  = src;
	vendorSha256 = "1drhpphcy2dz74zh9c9n2bq3qx6salyd8g5vwib7yz01hkyafi1m";
}
