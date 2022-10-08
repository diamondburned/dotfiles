{ pkgs }:

let newpkgs = import (pkgs.fetchFromGitHub {
		owner = "NixOS";
		repo  = "nixpkgs";
		rev   = "614a842";
		hash  = "sha256:0gkpnjdcrh5s4jx0i8dc6679qfkffmz4m719aarzki4jss4l5n5p";
	}) {};

	deps = with newpkgs; [
		gtk3
		gtk4
		glib
		librsvg
		libadwaita
		gdk-pixbuf
		gobject-introspection
		hicolor-icon-theme
		gst_all_1.gstreamer
		gst_all_1.gstreamer.dev
		gst_all_1.gst-plugins-base
		gst_all_1.gst-plugins-good
		gst_all_1.gst-plugins-bad
		gst_all_1.gst-plugins-ugly
	];
	
in pkgs.buildGoPackage {
	name = "grun";
	src  = pkgs.writeTextDir "main.go" ''
		package main

		import (
			"os"
			"os/exec"
			"log"
			"errors"
		)

		func main() {
			if len(os.Args) < 2 {
				log.Fatalln("usage: run [command...]")
			}

			cmd := exec.Command(os.Args[1], os.Args[2:]...)
			cmd.Stdin  = os.Stdin
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr

			if err := cmd.Run(); err != nil {
				var exitErr *exec.ExitError
				// Preserve exit code if possible.
				if errors.As(err, &exitErr) {
					os.Exit(exitErr.ExitCode())
				}

				log.Fatalln(err)
			}
		}
	'';

	goPackagePath = "github.com/diamondburned/grun";

	CGO_ENABLED = "0";

	buildInputs = deps;

	nativeBuildInputs = with pkgs; [
		wrapGAppsHook
		wrapGAppsHook4
	] ++ deps;
}
