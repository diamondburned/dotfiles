self: super:

let lib = super.lib;

	wlrootsPatch = wlroots: wlroots.overrideAttrs (old: {
		patches = (old.patches or []) ++ [
			(super.fetchurl {
				url    = "https://gitlab.freedesktop.org/wlroots/wlroots/-/merge_requests/2310.diff";
				sha256 = "192h6f7r3vdq64h1k2fdhac50nrjvjx70mz5w1zi6jqngf8h6pqb";
			})
		];
	});

	waylandPkgs = import <nixpkgs> {
		overlays = [
			(import <nix-wayland/overlay.nix>)
			(self: super: {
				wlroots      = wlrootsPatch super.wlroots;
				wlroots_0_14 = wlrootsPatch super.wlroots_0_14;
			})
		];
	};

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

	wf-shell = makeGApp waylandPkgs.wayfirePlugins.wf-shell;
	wayfire  = makeGApp waylandPkgs.wayfire;
}
