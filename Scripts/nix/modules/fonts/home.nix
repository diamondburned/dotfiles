{ config, lib, pkgs, ... }:

{
	fonts.fontconfig.enable = true;
	xdg.configFile."fontconfig/fonts.conf".source = <dotfiles/cfg/fontconfig.xml>;

	home.packages = with pkgs; [
		gucharmap
	];
}
