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
				rev    = "v0.7.0";
				sha256 = "0cnq06fyzvhbf9a8vs6ifhjjkvqgjjh2d39x58chiv84cm3wza6d";
				fetchSubmodules = true;
			};
			version = "0.7.0";
			passthru.providedSessions = [ "wayfire" ];
			buildInputs = old.buildInputs ++ (with pkgs; [
				libuuid
				gdk-pixbuf
				gnome3.glib
				gnome3.gtk3
			]);
			postInstall = ''
				mkdir -p "$out/share/wayland-sessions"
				cp ${./wayfire.desktop} \
					"$out/share/wayland-sessions/wayfire.desktop"
			'';
			# nativeBuildInputs = with pkgs; [ wrapGAppsHook ];
			# # dontWrapGApps = true;
			# # postFixup = ''
			# # 	ls $out/bin
			# # 	gappsWrapperArgsHook
			# # 	wrapProgram $out/bin/wayfire "''${gappsWrapperArgs[@]}"
			# # '';
		});
		wlroots = super.wlroots.overrideAttrs (old: {
			patches = (old.patches or []) ++ [
				../../patches/wlroots-10bit.patch
			];
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
