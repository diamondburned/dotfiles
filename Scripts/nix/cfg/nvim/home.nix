{ config, lib, pkgs, ... }:

{
	home.packages = with pkgs; [
		(wrapNeovimUnstable neovim-unwrapped
			# Use unstable Neovim with a slightly outdated Nixpkgs because
			# Copilot is fucking trash.
			(neovimUtils.makeNeovimConfig {
				vimAlias = true;
				withNodeJs = true;
				customRC = builtins.readFile ./init.vim;
				plugins = with pkgs.vimPlugins; [
					{ plugin = markdown-preview-nvim; }
				];
			})
		)
	];

	xdg.enable = true;
	xdg.configFile."nvim/lua/user" = {
		source = ./user;
		recursive = true;
	};
}
