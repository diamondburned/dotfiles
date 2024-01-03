{ config, lib, pkgs, ... }:

{
	programs.neovim = {
		enable = true;
		vimAlias = true;
		withNodeJs = true;
		withPython3 = true;
		defaultEditor = true;
		extraConfig = builtins.readFile ./init.vim;
		extraLuaConfig = builtins.readFile ./init.lua;
		plugins = with pkgs.vimPlugins; [
			# This thing is actually impossible to install via vim-plug,
			# so we get it from Nix instead.
			{ plugin = markdown-preview-nvim; }
		];
	};

	xdg.enable = true;
	xdg.configFile."nvim/lua/user" = {
		source = ./user;
		recursive = true;
	};
}
