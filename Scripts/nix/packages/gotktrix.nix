{ pkgs }:

let src = builtins.fetchGit {
	url = "https://github.com/diamondburned/gotktrix.git";
	ref = "compound";
};

in pkgs.callPackage "${src}/.nix/package.nix" {
	inherit src;
}
