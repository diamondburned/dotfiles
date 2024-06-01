{ pkgs }:

let
	sources = import <dotfiles/nix/sources.nix> { inherit pkgs; };
	src = sources.mtkclient;
in

pkgs.runCommandLocal "mtkclient-udev" {
	inherit src;
}
''
mkdir -p $out/etc/udev/rules.d
cp $src/mtkclient/Setup/Linux/*.rules $out/etc/udev/rules.d/
''
