{ pkgs }:

let gotktrix = pkgs.fetchFromGitHub {
		owner = "diamondburned";
		repo  = "gotktrix";
		rev   = "cff79bc112ac8c434de637c991f6d83eac7b2acb";
		hash  = "sha256:0xkk8zk2ykwdz46bcz8m1k0mw9xl23c4fknd8hwsx1bqz97qbl80";
	};

	gotk4-nix = pkgs.fetchFromGitHub {
		owner = "diamondburned";
		repo  = "gotk4-nix";
		rev   = "4f498cd56a726dc2ecb19af471cb43bb759708bb";
		hash  = "sha256:0009jbdj2y2vqi522a3r64xf4drp44ghbidf32j6bslswqf3wy4m";
	};

in pkgs.callPackage "${gotk4-nix}/package.nix" {
	base = (import "${gotktrix}/.nix/base.nix" // {
		vendorSha256 = "0cmandfdkczpppmf1kdxliw2b164a48vh9iqb46vizab69ynv7j7";
	});
}
