let nixosPkgs = import <nixos> {};
	lib = nixosPkgs.lib;

	waylandOverlays = import (nixosPkgs.fetchFromGitHub {
		owner  = "colemickens";
		repo   = "nixpkgs-wayland";
		rev    = "b9db16d610dc1ce6087cf4070e6394a11d0115fc";
		sha256 = "1l49m9ws72gkvx579y178h5zy4aydv62dz3lqcn382rgif4rzn9w";
	});

	waylandPkgs = import <nixos> {
		overlays = [ waylandOverlays ];
	};

in self: super: {
	wlroots = super.wlroots.overrideAttrs (old: {
		patches = (old.patches or []) ++ [
			../../patches/wlroots-10bit.patch
		];
	});
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
		patches = (old.patches or []) ++ [ ../sway/raise_floating.diff ];
	});
}
