{ pkgs, lib }:

pkgs.mixxx.overrideAttrs (old:
	if lib.versionAtLeast old.version "2.4"
	then { }
	else {
		src = pkgs.fetchFromGitHub {
			owner = "mixxxdj";
			repo = "mixxx";
			rev = "592c0c728e538fb57a1fbcf617fed2c0dc39085d"; # 2.4-beta
			sha256 = "sha256-/ysYBR2/oJXgz0LXdrca720O3T3WZf6GHOnyHa81EP0=";
			fetchSubmodules = true;
		};
		version = "2.4-beta";
		buildInputs = old.buildInputs ++ (with pkgs; [
			microsoft_gsl
		]);
		cmakeFlags = old.cmakeFlags ++ [
			"-DENGINEPRIME=OFF"
		];
	}
)
