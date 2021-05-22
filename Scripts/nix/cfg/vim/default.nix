{ config, lib, pkgs, ... }:

{
	programs.vim.enable = true;
	programs.vim.extraConfig = builtins.readFile ./vimrc;
	programs.vim.plugins = with pkgs; [
		ale
		nerdtree
		vim-autoswap
		vim-commentary
		vim-gitgutter
	];
	programs.vim.settings = {

	};
}
