{ pkgs }:

let
	bankstown = pkgs.callPackage ./lv2-bankstown.nix { };
in

pkgs.symlinkJoin {
	name = "asahi-lsp-plugins";
	paths = with pkgs; [
		lsp-plugins
		bankstown
	];
}
