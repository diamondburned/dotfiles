{ lib, pkgs }:

let waylandOverlays = import (pkgs.fetchFromGitHub {
		owner  = "colemickens";
		repo   = "nixpkgs-wayland";
		rev    = "b9db16d610dc1ce6087cf4070e6394a11d0115fc";
		sha256 = "1l49m9ws72gkvx579y178h5zy4aydv62dz3lqcn382rgif4rzn9w";
	});

	customOverlays = self: super: {
		wayfire = super.wayfire.overrideAttrs (old: {
			src = super.fetchFromGitHub {
				owner  = "diamondburned";
				repo   = "wayfire";
				rev    = "41633719868dfb76dad7a7564d4184d7894f7e76";
				sha256 = "1pm4sjidzs3kqbqn87176sn4ab5x1f0gvig90xmrvcb555vifc7g";
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
		});
		wlroots = super.wlroots.overrideAttrs (old: {
			patches = (old.patches or []) ++ [
				../../patches/wlroots-10bit.patch
			];
		});
	};

in import <nixos> {
	overlays = [ waylandOverlays customOverlays ];
}
