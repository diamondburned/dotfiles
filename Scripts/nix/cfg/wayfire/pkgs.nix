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
				owner  = "diamondburned";
				repo   = "wayfire";
				rev    = "2af834aa65b68fe9bec3a676da99066dd1bdec70";
				sha256 = "10agwd131dj2skd9jcgbqqlrbh1g39c7vqlgy27q4g74bwyqyifb";
				fetchSubmodules = true;
			};
			buildInputs = old.buildInputs ++ [ pkgs.libuuid ];
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
