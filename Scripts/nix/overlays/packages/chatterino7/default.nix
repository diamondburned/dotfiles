{ callPackage }:

let
	sources = import <dotfiles/nix/sources.nix> { };
	package = callPackage "${sources.notohh_snowflake}/pkgs/chatterino7" { };
in

package
