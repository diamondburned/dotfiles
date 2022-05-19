{ pkgs, fetchFromGitHub }:

# let src = fetchFromGitHub {
# 		owner = "diamondburned";
# 		repo  = "gappdash";
# 		rev   = "e8e2024";
# 		hash  = "sha256:11mih6m1xcm1knmn06cv2i4vqaxi522k8d99w942vr479s2waaxs";
# 	};
let src = /home/diamond/Scripts/gotk4/gappdash;

	# srcExtern = import "${src}/.nix/src.nix";
	# pkgExtern = import srcExtern.nixpkgs {
	# 	overlays = [ (import "${src}/.nix/overlay.nix") ];
	# };

	pkg = import "${src}/.nix/package.nix" {
		src  = src;
		pkgs = pkgs;
		internalPkgs = pkgs;
		vendorSha256 = "1wpwisk65rvil49809x7r0c5rdb3lrd21cvq0dhp9y21nrxia8ck";
	};

in pkg
