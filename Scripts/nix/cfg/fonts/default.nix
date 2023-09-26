{ config, lib, pkgs, ... }:

{
	fonts.fontconfig.enable = true;
	fonts.fontconfig.localConf = builtins.readFile <dotfiles/cfg/fontconfig.xml>;

	fonts.fonts = with pkgs; [
		bakoma_ttf # math
		# opensans-ttf
		roboto
		roboto-slab # serif
		source-code-pro
		source-sans-pro
		source-serif-pro
		fira-code
		material-design-icons
		inconsolata-nerdfont
		inconsolata
		comic-neue
		tewi-font
		unifont
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji
	];
}