{ fetchFromGitHub, pkgs }:

let
	lib = pkgs.lib;

	gnvim' = pkgs.callPackage <nixpkgs/pkgs/applications/editors/neovim/gnvim/wrapper.nix> {
		gnvim-unwrapped = pkgs.callPackage ./unwrapped.nix { };
	};
in
	gnvim'.overrideAttrs (old: {
		buildCommand = old.buildCommand + ''
			ln -s ${pkgs.nodePackages.neovim}/bin/neovim-node-host $out/bin/nvim-node
			wrapProgram $out/bin/gnvim \
				--prefix PATH : $out/bin \
				--prefix PATH : ${pkgs.nodejs_18}/bin
		'';
	})
