{ pkgs, lib, stdenv }:

stdenv.mkDerivation {
	name = "rhythmbox-alternative-toolbar";
	version = "0.19.3";

	src = builtins.fetchGit {
		url = "https://github.com/fossfreedom/alternative-toolbar.git";
		ref = "v0.19.3";
		rev = "84f15aa2c5f21e466c1fbf5d18c8967bfd69f5cd";
	};

	nativeBuildInputs = with pkgs; [
		pkg-config
		intltool perl perlPackages.XMLParser
		itstool
		autoreconfHook
		wrapGAppsHook
	];

	preConfigure = ''
		intltoolize --force
	'';

	buildInputs = with pkgs; [
		python3
		python3.pkgs.pygobject3
		libsoup
		tdb
		json-glib

		gtk3
		libpeas
		totem-pl-parser
		gnome.adwaita-icon-theme

		rhythmbox

		gst_all_1.gstreamer
		gst_all_1.gst-plugins-base
		gst_all_1.gst-plugins-good
		gst_all_1.gst-plugins-ugly
	];
}
