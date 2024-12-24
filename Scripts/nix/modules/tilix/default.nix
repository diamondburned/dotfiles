{ config, lib, pkgs, ... }:

{
	home.packages = with pkgs; [ tilix ];

	dconf.settings = {
		"com/gexperts/Tilix" = {
			"use-tabs" = true;
		};
		"com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d" = {
			"background-color" = "#555557575353";
			"background-transparency-percent" = 15;
			"cell-height-scale" = 1.0;
			"cursor-background-color" = "#FFFFFFFFFFFF";
			"cursor-colors-set" = true;
			"cursor-foreground-color" = "#000000000000";
			"dim-transparency-percent" = 10;
			"draw-margin" = 80;
			"font" = "Monospace 10";
			"foreground-color" = "#EEEEEEEEECEC";
			"palette" = [
				"#272722222424" "#FFFF47473D3D" "#3D3DCCCCB1B1" "#FFFF96960000" 
				"#3A3A7D7DCBCB" "#F7F74B4B6D6D" "#0000B5B5FCFC" "#3E3E3E3E3E3E"
				"#525249494C4C" "#FFFF69696161" "#8585E6E6D4D4" "#FFFFB3B34747" 
				"#77779E9ECBCB" "#F7F7A8A8B8B8" "#5454CCCCFCFC" "#EEEEEEEEECEC"
			];
			"scrollback-unlimited" = true;
			"terminal-bell" = "icon-sound";
			"use-system-font" = false;
			"use-theme-colors" = true;
			"visible-name" = "pastel";
		};
	};
}
