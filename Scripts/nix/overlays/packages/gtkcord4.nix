{ pkgs }:

let gtkcord4 = {
		src = pkgs.fetchFromGitHub {
			owner = "diamondburned";
			repo  = "gtkcord4";
			rev   = "0ac19003b75865378b8a36781cb9106741bc603f";
			hash  = "sha256:13wvbqqskrrczk3q2az18wmj6a7k79alrsnz0v7cijvm1bi1lrvk";
		};
		bin = pkgs.fetchzip {
			url = "https://github.com/diamondburned/gtkcord4/releases/download/v0.0.3-2/gtkcord4-nixos-x86_64.tar.gz";
			sha256 = "1n5c4lyydiq1y1h658wc7zg0nsrjl175ms3rpin2il40618w73z2";
		};
		base = import "${gtkcord4.src}/.nix/base.nix";
	};

	gotk4-nix = pkgs.fetchFromGitHub {
		owner = "diamondburned";
		repo  = "gotk4-nix";
		rev   = "4f498cd56a726dc2ecb19af471cb43bb759708bb";
		hash  = "sha256:0009jbdj2y2vqi522a3r64xf4drp44ghbidf32j6bslswqf3wy4m";
	};

	depsPkgs = import "${gotk4-nix}/pkgs.nix" {};

in pkgs.stdenv.mkDerivation rec {
	pname = gtkcord4.base.pname;
	version = "0.0.3";

	src = gtkcord4.bin;

	buildInputs = 
		(gtkcord4.base.buildInputs or (_: [])) depsPkgs ++
		(with depsPkgs; [
			gtk4
			glib
			librsvg
			gdk-pixbuf
			gobject-introspection
			hicolor-icon-theme
		]);

	nativeBuildInputs =
		(gtkcord4.base.nativeBuildInputs or (_: [])) pkgs ++
		(with pkgs; [ wrapGAppsHook autoPatchelfHook ]);

	sourceRoot = ".";

	installPhase = with gtkcord4.base; ''
		install -m755 -D "$src/${pname}" "$out/bin/${pname}"

		mkdir -p $out/share/icons/hicolor/256x256/apps/ $out/share/applications/
		cp ${files.desktop.path} $out/share/applications/${files.desktop.name}
		cp ${files.logo.path} $out/share/icons/hicolor/256x256/apps/${files.logo.name}
	'';
}
