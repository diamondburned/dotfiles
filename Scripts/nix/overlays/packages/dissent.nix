{ pkgs, lib }:

let
	dissent = rec {
		version = "0.0.15";

		src =
			if (false && builtins.pathExists /home/diamond/Scripts/gotk4/dissent) then
				/home/diamond/Scripts/gotk4/dissent
			else pkgs.fetchFromGitHub {
				owner  = "diamondburned";
				repo   = "dissent";
				rev    = "d5ceba11c52ffae801cdbde569416bcff246f3f0";
				sha256 = "sha256-iwMuZ7Y/Hzn1yAobID+rur1SNl/FEKBvQL6+kUt97zQ=";
			};

		base = import "${dissent.src}/nix/base.nix";
	};

	gotk4-nix = pkgs.fetchFromGitHub {
		owner = "diamondburned";
		repo  = "gotk4-nix";
		rev   = "4f498cd56a726dc2ecb19af471cb43bb759708bb";
		hash  = "sha256:0009jbdj2y2vqi522a3r64xf4drp44ghbidf32j6bslswqf3wy4m";
	};

in pkgs.stdenv.mkDerivation {
	pname = dissent.base.pname;
	inherit (dissent) version src;

	buildInputs = 
		(dissent.base.buildInputs or (_: [])) pkgs ++
		(with pkgs; [
			gtk4
			glib
			librsvg
			gdk-pixbuf
			gobject-introspection
			hicolor-icon-theme
		]);

	nativeBuildInputs =
		(dissent.base.nativeBuildInputs or (_: [])) pkgs ++
		(with pkgs; [ wrapGAppsHook autoPatchelfHook ]);

	sourceRoot = ".";

	buildPhase = with dissent.base; ''
		# install -Dm755 "$src/${pname}" "$out/bin/${pname}"
		mkdir -p \
			$out/share/dbus-1/services \
			$out/share/applications \
			$out/share/icons/hicolor/256x256/apps
		install -Dm644 ${src}/nix/so.libdb.dissent.service $out/share/dbus-1/services/so.libdb.dissent.service
		install -Dm644 ${files.desktop.path} $out/share/applications/${files.desktop.name}
		install -Dm644 ${files.logo.path} $out/share/icons/hicolor/256x256/apps/${files.logo.name}
	'';
}
