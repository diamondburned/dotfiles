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
	nixpkgs_pipewire_0_3_57 = import <nixpkgs_pipewire_0_3_57> nixpkgsOpts;
	nixpkgs_gradience = import <nixpkgs_gradience> nixpkgsOpts;

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
				nixpkgs_pipewire_0_3_57
				nixpkgs_gradience;
		})
		(nurOverlay)
		(import ./overrides.nix)
		(import ./packages/linux/overlay.nix)
		(import ./packages.nix)
	];
}
