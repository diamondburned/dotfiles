{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation {
	pname = "inconsolata";
	version = "unstable-0f203e3";

	src = fetchFromGitHub {
		owner = "google";
		repo = "fonts";
		rev = "0f203e3740b5eb77e0b179dff1e5869482676782";
		sha256 = "171fs9lifmm8pas12aiaw3ip3bf7f7lydww7wjw1v85494kr9is3";
	};

	installPhase = ''
		install -m644 --target $out/share/fonts/truetype/inconsolata -D $src/ofl/inconsolata/static/*.ttf
	'';

	meta = with lib; {
		homepage = "https://www.levien.com/type/myfonts/inconsolata.html";
		description = "A monospace font for both screen and print";
		maintainers = with maintainers; [ mikoim raskin ];
		license = licenses.ofl;
		platforms = platforms.all;
	};
}
