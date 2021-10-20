let nixosPkgs = import <nixos> {};
	lib = nixosPkgs.lib;

	waylandOverlays = import (nixosPkgs.fetchFromGitHub {
		owner  = "nix-community";
		repo   = "nixpkgs-wayland";
		rev    = "5a8d934666de00b7e3ad78967350ad0a1f2ed4c7";
		sha256 = "1007wzy1lgj86g2yw7kbgxrzrl288cj29b3bwmmxv7zs0r3qqb7z";
	});

	waylandPkgs = import <unstable> {
		overlays = [ waylandOverlays ];
	};

	wf-config = waylandPkgs.wayfire.overrideAttrs (old: {
		name = "wf-config";
		version = "0.8.0";

		src = builtins.fetchGit {
			url = "git@github.com:WayfireWM/wf-config.git";
			rev = "145470ddd0d1c3b7080220e4f30cc78f377d5dc0";
		};

		# mesonFlags = [ "-Dwlroots:x11-backend=disabled" ];
	});

in self: super: {
	inherit (waylandPkgs) wlogout wlsunset;

	# Broken.
	# wlroots = waylandPkgs.wlroots.overrideAttrs (old: {
	# 	patches = (old.patches or []) ++ [
	# 		../../patches/wlroots-10bit.patch
	# 	];
	# });

	wayfire-session = super.runCommand "wayfire-session" {
		passthru.providedSessions = [ "wayfire" ];
	} ''
		mkdir -p "$out/share/wayland-sessions"
		cp ${./wayfire.desktop} \
			"$out/share/wayland-sessions/wayfire.desktop"	
	'';

	# wayfire-unwrapped = super.wayfireApplications-unwrapped.wayfire.overrideAttrs (old: {
	# 	# version = "0.7.2";
	# 	# src = super.fetchFromGitHub {
	# 	# 	owner  = "WayfireWM";
	# 	# 	repo   = "wayfire";
	# 	# 	rev    = "7a69c1e3c0fe0cd0134db6d8fe581d9d831f648e";
	# 	# 	sha256 = "${super.lib.fakeSha256}";
	# 	# 	fetchSubmodules = true;
	# 	# };
	# 	passthru.providedSessions = [ "wayfire" ];
	# 	postInstall = ''
	# 		mkdir -p "$out/share/wayland-sessions"
	# 		cp ${./wayfire.desktop} \
	# 			"$out/share/wayland-sessions/wayfire.desktop"
	# 	'';
	# });

	# wayfireApplications-unwrapped = super.wayfireApplications-unwrapped // {
	# 	wayfire = self.wayfire-unwrapped;
	# };
	# wayfire = self.wayfire-unwrapped;

	wf-shell = super.wayfirePlugins.wf-shell.overrideAttrs(old: {
		nativeBuildInputs = old.nativeBuildInputs ++ (with super; [ wrapGAppsHook ]);
	});
	# wf-shell = waylandPkgs.wayfirePlugins.wf-shell;

	# wf-shell = super.stdenv.mkDerivation rec {
	# 	name = "wf-shell-0.7.0";
	# 	src  = super.fetchFromGitHub {
	# 		owner  = "WayfireWM";
	# 		repo   = "wf-shell";
	# 		rev    = "v0.7.0";
	# 		sha256 = "1q54ivzb81wxbmyyggsi45jcbhdhilp49g8fskwyfrnvv2w021c9";
	# 		fetchSubmodules = true;
	# 	};

	# 	enableParallelBuilding = true;

	# 	nativeBuildInputs = with super; [
	# 		meson
	# 		ninja
	# 		pkgconfig
	# 	];

	# 	buildInputs = with super; [
	# 		self.wf-config
	# 		self.wayfire

	# 		wayland
	# 		wayland-protocols
	# 		wayland-utils
	# 		waylandpp
	# 		gnome3.gtkmm3.dev
	# 		gnome3.gtk.dev
	# 		gtk-layer-shell
	# 		libpulseaudio
	# 		alsaLib.dev
	# 		graphviz
	# 		glm
	# 	];
	# };

# 	sway-unwrapped = super.sway-unwrapped.overrideAttrs (old: {
# 		patches = (old.patches or []) ++ [ ../sway/raise_floating.diff ];
# 	});
}
