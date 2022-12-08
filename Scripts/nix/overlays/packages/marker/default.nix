{ pkgs, lib, stdenv, fetchgit }:

# let scidown = stdenv.mkDerivation rec {
# 	name = "scidown";
# 	version = "v0.1.0";

# 	src = fetchgit {
# 		url = "https://github.com/Mandarancio/scidown.git";
# 		rev = "99b5d1803a68dd351058029b413b61235c0604c6";
# 		sha256 = lib.fakeSha256;
# 		deepClone = true;
# 	};

# 	nativeBuildInputs = with pkgs; [
# 		meson
# 	];
# };

stdenv.mkDerivation rec {
	name = "marker";
	version = "2020.04.04";

	src = fetchgit {
		url = "https://github.com/fabiocolacio/Marker.git";
		rev = "f120817e2877edf5dd6e42a0bd28a4209a4171e6";
		sha256 = "0vlx238xrzyr3h52ws011ac2h6qrcv78b34ajg2050d85p9aaipi";
		deepClone = true;
	};

	nativeBuildInputs = with pkgs; [
		ninja meson pkg-config wrapGAppsHook
	];

	buildInputs =  (with pkgs; [
		gtkspell3
		webkitgtk
		gnome.gtk
		gnome.glib
		gnome.gtksourceview
	]);
}
