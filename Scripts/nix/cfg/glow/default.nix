{ config, lib, pkgs, ... }:

let cfg = {
	mouse = true;
	pager = false;
	width = 80;
	style = ./pink.json;
};

in {
	xdg.configFile."glow/glow.yml".text = builtins.toJSON cfg;
	home.packages = with pkgs; [ glow ];
}
