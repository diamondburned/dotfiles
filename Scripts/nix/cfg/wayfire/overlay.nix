let nixosPkgs = import <nixpkgs> {};
	lib = nixosPkgs.lib;

	waylandOverlays = import (nixosPkgs.fetchFromGitHub {
		owner  = "nix-community";
		repo   = "nixpkgs-wayland";
		rev    = "a1c9b58";
		sha256 = "1c9dxdw3r5g71wwnpqvnifzpb41005yg7mmzsjjk8kpkfrh5cb4q";
	});

	waylandPkgs = import <nixpkgs> {
		overlays = [
			(import <nix-wayland/overlay.nix>)
		];
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

	makeGApp = pkgs: pkg: pkg.overrideAttrs(old: {
		nativeBuildInputs = old.nativeBuildInputs ++ (with pkgs; [ wrapGAppsHook ]);
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

	labwc-session = super.runCommand "labwc-session" {
		passthru.providedSessions = [ "labwc" ];
	} ''
		mkdir -p "$out/share/wayland-sessions"
		cp ${./labwc.desktop} \
			"$out/share/wayland-sessions/labwc.desktop"	
	'';

	wf-shell = makeGApp super super.wayfirePlugins.wf-shell;
	wayfire  = makeGApp super super.wayfire;
}
