{ pkgs, lib }:

let gtkcord4 = rec {
		version = "0.0.14";
		hashes = {
			src = "${lib.fakeSha256}";
			bin = {
				arm64 = "${lib.fakeSha256}";
				amd64 = "sha256-Tfss14NPhJ12qQ86yhWgHd57y+UGdPxkTefY0HbJRUY=";
			};
		};

		src = pkgs.fetchFromGitHub {
			owner  = "diamondburned";
			repo   = "gtkcord4";
			rev    = "v${version}";
			sha256 = "sha256-LG2fWJ5ycKz2r0CjJIpies69pFxVxG42+FKayrT9Dhs=";
		};

		arch =
			if pkgs.stdenv.isx86_64 then "amd64"
			else if pkgs.stdenv.isAarch64 then "arm64"
			else throw "Unsupported architecture";

		bin = pkgs.runCommand "gtkcord4-bin" {
			src = pkgs.fetchurl {
				url = "https://github.com/diamondburned/gtkcord4/releases/download/v${version}/gtkcord4-linux-${arch}-v${version}-.tar.zst";
				sha256 = hashes.bin.${arch};
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
