{ pkgs }:

let gotktrix = pkgs.fetchFromGitHub {
		owner = "diamondburned";
		repo  = "gotktrix";
		rev   = "cff79bc112ac8c434de637c991f6d83eac7b2acb";
		hash  = "sha256:0xkk8zk2ykwdz46bcz8m1k0mw9xl23c4fknd8hwsx1bqz97qbl80";
	};

	gotk4-nix = /home/diamond/Scripts/gotk4/gotk4-nix;
 	# gotk4-nix = pkgs.fetchFromGitHub {
 	# 	owner = "diamondburned";
 	# 	repo  = "gotk4-nix";
 	# 	rev   = "a1019265fe21b060240db4456bcf631a9378bb71";
 	# 	hash  = "sha256:0s1gnw9qm799m0ia66n64inih23smg0xqqkpldlyplhlzvkdrvk6";
 	# };

	gotk4-pkgs = import "${gotk4-nix}/pkgs.nix" {};

in import "${gotk4-nix}/package.nix" {
	pkgs = gotk4-pkgs;
	base = (import "${gotktrix}/.nix/base.nix") // {
		vendorSha256 = "0cmandfdkczpppmf1kdxliw2b164a48vh9iqb46vizab69ynv7j7";
	};
	doCheck = false;
}
