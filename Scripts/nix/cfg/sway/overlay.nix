let waylandPkgs = import ./waylandpkgs.nix;

in self: super: {
	wf-shell = super.stdenv.mkDerivation rec {
		name = "wf-shell-3e31442-css-patched";
		src  = super.fetchFromGitHub {
			owner  = "diamondburned";
			repo   = "wf-shell";
			rev    = "3e31442569d1962e8efe58685ca09160e21ba146";
			sha256 = "054xybdwhdn3g295q1dy2nv1yxd291kl548x2zy7x2r86s6fkmb9";
			fetchSubmodules = true;
		};

		enableParallelBuilding = true;

		nativeBuildInputs = with super; [
			meson
			ninja
			pkgconfig
		];

		buildInputs = [ waylandPkgs.wayfire ] ++ (with super; [
			gnome3.gtkmm3.dev
			gnome3.gtk.dev
			wayland
			wayland-protocols
			wayland-utils
			waylandpp
			gtk-layer-shell
			libpulseaudio
			alsaLib.dev
			graphviz
			glm
		]);
	};

	sway-unwrapped = super.sway-unwrapped.overrideAttrs (old: {
		patches = (old.patches or []) ++ [ ./raise_floating.diff ];
	});
}
