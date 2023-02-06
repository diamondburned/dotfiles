{ pkgs }:

let gtkcord4 = rec {
		version = "0.0.8";
		hashes = {
			src = "sha256:1sqn08hapgbkb5vmw562a03a1b178a887r492k49c245sa9mb538";
			bin = "sha256:0swp5pb7w6j622kbp7qkzyi321fch8wwbq6d9i83w8cg3gh9payp";
		};

		src = pkgs.fetchFromGitHub {
			owner = "diamondburned";
			repo  = "gtkcord4";
			rev   = "v${version}";
			hash  = hashes.src;
		};

		bin = pkgs.runCommand "gtkcord4-bin" {
			src = pkgs.fetchurl {
				url = "https://github.com/diamondburned/gtkcord4/releases/download/v${version}/gtkcord4-linux-amd64-v0.0.8-libadwaita.tar.zst";
				sha256 = hashes.bin;
			};
			nativeBuildInputs = with pkgs; [
				zstd
			];
		} ''
			tar --zstd -xf $src
			mkdir -p $out/bin
			cp bin/gtkcord4 $out/
			chmod +x $out/*
		'';

		base = import "${gtkcord4.src}/nix/base.nix";
	};

	gotk4-nix = pkgs.fetchFromGitHub {
		owner = "diamondburned";
		repo  = "gotk4-nix";
		rev   = "4f498cd56a726dc2ecb19af471cb43bb759708bb";
		hash  = "sha256:0009jbdj2y2vqi522a3r64xf4drp44ghbidf32j6bslswqf3wy4m";
	};

	depsPkgs = import "${gotk4-nix}/pkgs.nix" {};

in pkgs.stdenv.mkDerivation {
	pname = gtkcord4.base.pname;
	inherit (gtkcord4) version;

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
