let
	overlays = [
		# (import <dotfiles/overlays/overrides.nix>)
		(import <dotfiles/overlays/overrides-all.nix>)
		(import <dotfiles/overlays/packages.nix>)
	];

	opts = {
		config.allowUnfree = true;
		inherit overlays;
	};
in

[
	(self: super: {
		nixpkgs_staging = import <nixpkgs_staging> opts;
		nixpkgs_unstable = import <nixpkgs_unstable> opts;
	})
] ++ overlays
