{ config, lib, pkgs, ... }:

{
	fonts.fontconfig.enable = true;
	fonts.fontconfig.localConf = builtins.readFile <dotfiles/cfg/fontconfig.xml>;

	fonts.packages = with pkgs; [
		# corefonts
		wqy_zenhei # for TF2
		bakoma_ttf # math
		# opensans-ttf
		lexend
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
		noto-fonts-cjk-sans
		noto-fonts-emoji
	];

	fonts.fontconfig.defaultFonts = {
		serif = [
			"serif"
			"Noto Serif"
		];
		sansSerif = [
			"sans-serif"
			"Open Sans"
			"Source Sans 3"
			"Source Sans Pro"
			"Noto Sans"
		];
		monospace = [
			"Inconsolata"
			"Symbols Nerd Font"
			"Source Code Pro"
			"Noto	Sans Mono"
			"emoji"
			"symbol"
			"Unifont"
			"Unifont Upper"
		];
		emoji = [
			"Noto Color Emoji"
		];
	};
}
