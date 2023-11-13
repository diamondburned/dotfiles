let
	nixpkgsOpts = { };
in

[
	(self: super: {
		nixpkgs_gnome = import <nixpkgs_gnome> nixpkgsOpts;
		nixpkgs_unstable_real = import <unstable> nixpkgsOpts;
	})
	(import ./nixgl.nix)
	# (import <dotfiles/cfg/gnome/gnome-45-overlay.nix>)
]
