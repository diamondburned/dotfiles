{ stdenv, pkgs, lib }:

stdenv.mkDerivation rec {
	pname = "srain";
	version = "9b1a45e";

	name = "${pname}-${version}";

	src = pkgs.fetchFromGitHub {
		owner  = "SrainApp";
		repo   = "srain";
		sha256 = "1czavd39xn8gwxghlw14vl58fz4lw1xyblvrjha58yxbfpss08wn";
		rev    = "9b1a45ed69179f14fcf794cd6d8cbf0803b2f862";
	};

	nativeBuildInputs = with pkgs; [
		meson
		ninja
		gettext
		coreutils
		pkg-config
		wrapGAppsHook

		python37Packages.sphinx
	];

	mesonFlags = "-Ddoc_builders=[]";
	mesonBuildType = "release";
	mesonAutoFeatures = "disabled";

	buildInputs = with pkgs; [
		glib
		glib-networking
		gtk3
		gnome3.libsoup
		gnome3.libsecret

		libconfig
		openssl
	];

	preFixup = ''
		gappsWrapperArgs+=(
			--prefix XDG_DATA_DIRS : "${pkgs.gnome3.glib-networking}/share"
			--prefix XDG_DATA_DIRS : "${pkgs.gnome3.libsoup}/share"
			--prefix XDG_DATA_DIRS : "${pkgs.gnome3.libsecret}/share"
		)
	'';
}
