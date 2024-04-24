{ pkgs, chatterino2 }:

let
	sources = import <dotfiles/nix/sources.nix> { };

	libcommuni = pkgs.qt6.callPackage ./libcommuni.nix { };

	package = chatterino2.overrideAttrs (old: {
		pname = "chatterino7";
		src = sources.chatterino7;
		buildInputs = old.buildInputs ++ [
			libcommuni
		];
	});
in

package
