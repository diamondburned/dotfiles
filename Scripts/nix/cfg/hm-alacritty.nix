{ config, lib, pkgs, ... }: {
	programs.alacritty.enable = true;
	programs.alacritty.settings = {
		font = let font = { family = "monospace"; }; in {
			normal = font;
			bold   = font;
			italic = font;
			size   = 11;
		};
		window = {
			# Keep same as gtk.css.
			padding = { x = 6; y = 4; };
			dynamic_padding = true;
		};
		colors.primary.background = "#1D1D1D";
		colors.primary.foreground = "#E5E5E5";
		normal = {
			black = "#272224";
			red = "#FF473D";
			green = "#3DCCB2";
			yellow = "#FF9600";
			blue = "#3B7ECB";
			magenta = "#F74C6D";
			cyan = "#00B5FC";
			white = "#3E3E3E";
		};
		bright = {
			black = "#52494C";
			red = "#FF6961";
			green = "#85E6D4";
			yellow = "#FFB347";
			blue = "#779ECB";
			magenta = "#F7A8B8";
			cyan = "#55CDFC";
			white = "#EEEEEC";
		};
	};
}
