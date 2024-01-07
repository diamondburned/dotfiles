{ pkgs, lib }:

let
	gtkcord4 = rec {
		version = "0.0.15";
		hashes = {
			src = "${lib.fakeSha256}";
			bin = {
				arm64 = "sha256-KBHCQWNh48OVi2UqW3L5Icqb2ctC+dzezH0w8a2T6jY=";
				amd64 = "sha256-0QV8ebVMtv4EKsbzbRLXKy1E7CYNGW3mHFguyQN33vo=";
			};
		};

		src =
			if (builtins.pathExists /home/diamond/Scripts/gotk4/gtkcord4) then
				/home/diamond/Scripts/gotk4/gtkcord4
			else pkgs.fetchFromGitHub {
				owner  = "diamondburned";
				repo   = "gtkcord4";
				rev    = "2d86201c37ba7d4706ef33296cadb34049ec6a0d";
				sha256 = "sha256-vlZlHHHSPf2aejT0i4HP+KpHKyDn+pUZQVYIxRH0YNk=";
			};

		base = import "${gtkcord4.src}/nix/base.nix";
	};

	gotk4-nix = pkgs.fetchFromGitHub {
		owner = "diamondburned";
		repo  = "gotk4-nix";
		rev   = "4f498cd56a726dc2ecb19af471cb43bb759708bb";
		hash  = "sha256:0009jbdj2y2vqi522a3r64xf4drp44ghbidf32j6bslswqf3wy4m";
	};

in pkgs.stdenv.mkDerivation {
	pname = gtkcord4.base.pname;
	inherit (gtkcord4) version src;

	buildInputs = 
		(gtkcord4.base.buildInputs or (_: [])) pkgs ++
		(with pkgs; [
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

	buildPhase = with gtkcord4.base; ''
		install -Dm755 "$src/${pname}" "$out/bin/${pname}"
		mkdir -p \
			$out/share/dbus-1/services \
			$out/share/applications \
			$out/share/icons/hicolor/256x256/apps
		install -Dm644 ${src}/nix/so.libdb.gtkcord4.service $out/share/dbus-1/services/so.libdb.gtkcord4.service
		install -Dm644 ${files.desktop.path} $out/share/applications/${files.desktop.name}
		install -Dm644 ${files.logo.path} $out/share/icons/hicolor/256x256/apps/${files.logo.name}
	'';
}
