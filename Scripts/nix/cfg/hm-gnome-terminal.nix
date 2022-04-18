{ config, lib, pkgs, ... }: {
	dconf.settings = {
		"org/gnome/terminal/legacy".headerbar = lib.hm.gvariant.mkJust true;
	};

	programs.gnome-terminal.enable  = true;
	programs.gnome-terminal.profile = {
		"f2afd3c7-cb35-4d08-b6c2-523b444be64d" = {
			scrollOnOutput = false;
			visibleName   = "pastel";
			showScrollbar = false;
			default = true;

			font	= "Inconsolata Bold 10";
			colors  = {
				backgroundColor = "#1D1D1D";
				foregroundColor = "#FFFFFF";
				# foregroundColor = "#E5E5E5";
				palette = [
					"#272224" "#FF473D" "#3DCCB2" "#FF9600"
					"#3B7ECB" "#F74C6D" "#00B5FC" "#3E3E3E"

					"#52494C" "#FF6961" "#85E6D4" "#FFB347"
					"#779ECB" "#F7A8B8" "#55CDFC" "#EEEEEC"
				];
			};
		};
		"bade9a23-9fab-4bbb-9798-3dacbccd8e6c" = {
			visibleName  = "Google Light";
			showScrollbar = false;

			font   = "Inconsolata Bold 10";
			colors = {
				backgroundColor = "#FEFEFE";
				foregroundColor = "#373B41";
				palette = [
					"#1d1f21" "#cc342b" "#198844" "#fba922"
					"#3971ed" "#a36ac7" "#3971ed" "#c5c8c6"

					"#969896" "#cc342b" "#198844" "#fba922"
					"#3971ed" "#a36ac7" "#3971ed" "#252525"
				];
			};
		};
	};
}
