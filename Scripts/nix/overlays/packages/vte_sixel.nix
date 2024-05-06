{ lib, vte, lz4, fetchurl }:

vte.overrideAttrs (old: rec {
	mesonFlags = old.mesonFlags ++ [
		# Enable SIXEL.
		"-Dsixel=true"
	];
})
