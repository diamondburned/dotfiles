{ lib, pkgs }:

let waylandOverlays = import (pkgs.fetchFromGitHub {
		owner  = "colemickens";
		repo   = "nixpkgs-wayland";
		rev    = "dab1b3d6ea5ca67b76f6e54f1da798094c856708";
		sha256 = "1br0a238cdr63fgwvkzyvwnplcik91242xflak6wvnip77zp9xy2";
	});

	customOverlays = self: super: {
		# wayfire = super.wayfire.overrideAttrs (old: {
		# 	version = "0.7.0";
		# 	passthru.providedSessions = [ "wayfire" ];
		# 	buildInputs = old.buildInputs ++ (with pkgs; [
		# 		libuuid
		# 		gdk-pixbuf
		# 		gnome3.glib
		# 		gnome3.gtk3
		# 	]);
		# 	postInstall = ''
		# 		mkdir -p "$out/share/wayland-sessions"
		# 		cp ${./wayfire.desktop} \
		# 			"$out/share/wayland-sessions/wayfire.desktop"
		# 	'';
		# });
		# wlroots = super.wlroots.overrideAttrs (old: {
		# 	patches = (old.patches or []) ++ [
		# 		../../patches/wlroots-10bit.patch
		# 	];
		# });
	};

in import <nixos> {
	# overlays = [ waylandOverlays customOverlays ];
}
