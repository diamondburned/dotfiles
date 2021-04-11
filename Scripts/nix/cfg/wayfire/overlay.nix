let nixosPkgs = import <nixos> {};
	lib = nixosPkgs.lib;

	waylandOverlays = import (nixosPkgs.fetchFromGitHub {
		owner  = "colemickens";
		repo   = "nixpkgs-wayland";
		rev    = "e90c00ca1ddd295ecb53d9059be92c5ca7d75748";
		sha256 = "060jpzhylysxqlv1qfl2bl5if71lkn217ss44b0w9nyxc1286sww";
	});

	waylandPkgs = import <nixos> {
		overlays = [ waylandOverlays ];
	};

in self: super: {
	inherit (waylandPkgs) wlogout wlsunset;

	# Broken.
	# wlroots = waylandPkgs.wlroots.overrideAttrs (old: {
	# 	patches = (old.patches or []) ++ [
	# 		../../patches/wlroots-10bit.patch
	# 	];
	# });

	wayfire = waylandPkgs.wayfire.overrideAttrs (old: {
		src = super.fetchFromGitHub {
			owner  = "diamondburned";
			repo   = "wayfire";
			rev    = "41633719868dfb76dad7a7564d4184d7894f7e76";
			sha256 = "0h6zfr6a5k90hnrw0hmmgig5v17xhry0vzyf7lgw057c4lqrvqjc";
			fetchSubmodules = true;
		};

		version = "0.7.0";
		passthru.providedSessions = [ "wayfire" ];
		buildInputs = old.buildInputs ++ (with super; [
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

	wf-shell = super.stdenv.mkDerivation rec {
		name = "wf-shell-3e31442-css-patched";
		src  = super.fetchFromGitHub {
			owner  = "WayfireWM";
			repo   = "wf-shell";
			rev    = "v0.7.0";
			sha256 = "1q54ivzb81wxbmyyggsi45jcbhdhilp49g8fskwyfrnvv2w021c9";
			fetchSubmodules = true;
		};

		enableParallelBuilding = true;

		nativeBuildInputs = with super; [
			meson
			ninja
			pkgconfig
		];

		buildInputs = with super; [
			self.wf-config
			self.wayfire

			wayland
			wayland-protocols
			wayland-utils
			waylandpp
			gnome3.gtkmm3.dev
			gnome3.gtk.dev
			gtk-layer-shell
			libpulseaudio
			alsaLib.dev
			graphviz
			glm
		];
	};

# 	sway-unwrapped = super.sway-unwrapped.overrideAttrs (old: {
# 		patches = (old.patches or []) ++ [ ../sway/raise_floating.diff ];
# 	});
}
