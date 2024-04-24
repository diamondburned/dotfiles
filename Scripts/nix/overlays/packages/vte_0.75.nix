{ lib, vte, lz4, fetchurl }:

vte.overrideAttrs (old: rec {
	version = "0.75.0";

	src = fetchurl {
		url = "mirror://gnome/sources/vte/${lib.versions.majorMinor version}/vte-${version}.tar.xz";
		sha256 = "sha256-q95FMcPIfkZFTIbOFgOr8vEwCqCWx0YtWEF5YccsFvo=";
	};

	mesonFlags = old.mesonFlags ++ [
		# Enable SIXEL.
		"-Dsixel=true"
	];

	buildInputs = old.buildInputs ++ [
		lz4
	];
})
