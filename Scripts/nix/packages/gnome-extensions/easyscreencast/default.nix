{ stdenv, glib, gettext }:

stdenv.mkDerivation rec {
	pname = "gnome-shell-easyscreencast";
	version = "1.1.0";

	src = builtins.fetchGit {
		url = "https://github.com/EasyScreenCast/EasyScreenCast.git";
		rev = "4d48548aecdddf15267554a91cca1bba85328c4f";
		ref = version;
	};

	buildInputs = [
		glib gettext
	];

	makeFlags = [ "INSTALLBASE=$(out)/share/gnome-shell/extensions" ];

	meta = with pkgs.lib; {
		license = licenses.gpl3;
	};
}
