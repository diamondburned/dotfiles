{
	stdenv, fetchurl, makeWrapper, pkg-config, wrapGAppsHook, intltool,
	gnome3, gnome2, libxml2, glib, id3lib, libogg,
}:

stdenv.mkDerivation rec {
	pname = "tagtool";
	version = "0.12.3";

	name = "${pname}-${version}";

	src = fetchurl {
		url = "https://gigenet.dl.sourceforge.net/project/${pname}/${pname}/${version}/${name}.tar.bz2";
		sha256 = "04flsfliiiawf19qrkg9bhd86llh3p3zsr8qkp081bfj3l1l2gr7";
	};

	buildInputs = [ 
		# GUI libs
		glib libxml2 
		gnome3.adwaita-icon-theme 
		gnome2.gtk
		gnome2.libglade

		# Audio libs
		id3lib
		libogg
	];
	nativeBuildInputs = [ intltool pkg-config wrapGAppsHook ];

	meta = with pkgs.lib; {
		description = "Program to manage the tags in MP3 and Ogg Vorbis files";
		longDescription = ''
			Audio Tag Tool is a program to manage the information fields in MP3
			and Ogg Vorbis files, commonly called tags. It can be used to edit
			tags one by one, but the most useful features are mass tag and mass
			rename. These are designed to tag or rename hundreds of files at
			once, in any desired format.
		'';
		homepage = http://freshmeat.sourceforge.net/projects/audiotagtool;
		license = licenses.gpl2;
		platforms = platforms.linux;
	};
}
