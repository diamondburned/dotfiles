{ lib, pkgs }:

let waylandOverlays = import (pkgs.fetchFromGitHub {
		owner  = "colemickens";
		repo   = "nixpkgs-wayland";
		rev    = "b9db16d610dc1ce6087cf4070e6394a11d0115fc";
		sha256 = "1l49m9ws72gkvx579y178h5zy4aydv62dz3lqcn382rgif4rzn9w";
	});

	customOverlays = self: super: {
		wayfire  = super.wayfire.overrideAttrs (old: {
			src  = super.fetchFromGitHub {
				owner  = "WayfireWM";
				repo   = "wayfire";
				rev    = "0.6.0";
				sha256 = "1glrfzz0dk1xgljk71vl138zpsdc765w29ik9x5dqcnwjj2sq4px";
				fetchSubmodules = true;
			};
			version = "0.6.0";
		});
		wf-shell = super.wayfire.overrideAttrs (old: {
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

			buildInputs = with super; [
				wayfire
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
			];
		});
	};

in import <nixos> {
	overlays = [ waylandOverlays customOverlays ];
}
