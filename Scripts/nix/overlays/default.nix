{ lib, pkgs, config, ... }:

let nurOverlay =
	(self: super:
		(import ./nur.nix
			(import <nur> { pkgs = super; })
			self super));

	nixpkgsOpts = {
		config.allowUnfree = true;
		overlays = [
			# TODO: move the massive overlays list to a separate file and import them to all of our
			# Nixpkgs.
			(import ./overrides-all.nix)
			(import ./packages/linux/overlay.nix)
			(import ./packages.nix)
			(nurOverlay)
		];
	};

	nixpkgs_21_11 = import <nixpkgs_21_11> nixpkgsOpts;
	nixpkgs_staging = import <nixpkgs_staging> nixpkgsOpts;
	nixpkgs_unstable = import <nixpkgs_unstable> nixpkgsOpts;
	nixpkgs_unstable_real = import <unstable> nixpkgsOpts;
	nixpkgs_unstable_newer = import <nixpkgs_unstable_newer> nixpkgsOpts;
	nixpkgs_unstable_older = import <nixpkgs_unstable_older> nixpkgsOpts;
	nixpkgs_gradience = import <nixpkgs_gradience> nixpkgsOpts;
	nixpkgs_linux_6_1_9 = import <nixpkgs_linux_6_1_9> nixpkgsOpts;

in {
	nixpkgs.overlays = [
		(self: super: {
			# Expose these for the system to use.
			inherit
				nixpkgs_21_11
				nixpkgs_staging
				nixpkgs_unstable
				nixpkgs_unstable_real
				nixpkgs_unstable_newer
				nixpkgs_unstable_older
				nixpkgs_gradience
				nixpkgs_linux_6_1_9;
		})
		(nurOverlay)
    (import <gomod2nix/overlay.nix>)
		(import ./overrides.nix)
		(import ./overrides-all.nix)
		(import ./packages/linux/overlay.nix)
		(import ./packages.nix)
	];
}
