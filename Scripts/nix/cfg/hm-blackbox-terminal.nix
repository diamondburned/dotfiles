{ config, lib, pkgs, ... }:

let
	withBlackboxTheme = { name, ... }@args: {
		xdg.enable = true;
		xdg.dataFile."blackbox/schemes/${lib.toLower name}.json".text = builtins.toJSON args;
	};

	blackbox-terminal = pkgs.blackbox-terminal.override {
		vte-gtk4 = pkgs.callPackage <dotfiles/overlays/packages/vte_0.75.nix> {
			vte = pkgs.vte-gtk4;
		};
	};

in {
	imports = [
		(withBlackboxTheme {
			name = "Pastel";
			comment = "";
			use-theme-colors = false;
			foreground-color = "#E5E5E5";
			background-color = "#1D1D1D";
			palette = [
				"#272224" "#FF473D" "#3DCCB2" "#FF9600"
				"#3B7ECB" "#F74C6D" "#00B5FC" "#3E3E3E"

				"#52494C" "#FF6961" "#85E6D4" "#FFB347"
				"#779ECB" "#F7A8B8" "#55CDFC" "#EEEEEC"
			];
		})
	];

	home.packages = [
		blackbox-terminal
	];
}
