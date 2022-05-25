self: super:

let nixosPkgs = import <nixos> {};
	lib = nixosPkgs.lib;

	waylandPkgs = import <nixos> {
		overlays = [ (import <nix-wayland/overlay.nix>) ];
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

	makeGApp = old: old.overrideAttrs(old: {
		buildInputs = (old.buildInputs or []) ++ (with super; [
			gtk3
			glib
			gdk-pixbuf
			librsvg
		]);
		nativeBuildInputs = (old.nativeBuildInputs or []) ++ (with super; [
			wrapGAppsHook
		]);
	});

in {
	inherit (waylandPkgs)
		wlogout
		wlsunset;

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

	wf-shell = makeGApp super.wayfirePlugins.wf-shell;
	wayfire  = makeGApp super.wayfire;
	# wayfire  = makeGApp waylandPkgs.wayfire;
}
