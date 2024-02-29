{ config, lib, pkgs, ... }:

let
	sources = {
		sgNvim = pkgs.fetchFromGitHub {
			owner = "sourcegraph";
			repo = "sg.nvim";
			rev = "v1.0.8";
			sha256 = "sha256-maseTcgKISXRmM88t6RAf9pCpjT/+lo29eLzCLciAMg=";
		};
		sgNvimBinaries = {
			x86_64-linux = pkgs.fetchzip {
				url = "https://github.com/sourcegraph/sg.nvim/releases/download/v1.0.8/sg-x86_64-unknown-linux-gnu.tar.xz";
				sha256 = "sha256-lbimCt+YbE2oJlKma/SyL/BVa4c132IzVOL/W6ofh7Y=";
			};
			aarch64-linux = pkgs.fetchzip {
				url = "https://github.com/sourcegraph/sg.nvim/releases/download/v1.0.8/sg-aarch64-unknown-linux-gnu.tar.xz";
				sha256 = "";
			};
		};
	};
in

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
			markdown-preview-nvim
		];
	};

	xdg.enable = true;
	xdg.configFile."nvim/lua/user" = {
		source = ./user;
		recursive = true;
	};

	home.packages = with pkgs; [
		neovide
	];

	# sourcegraph/sg.nvim requires a Rust binary (no one asked for Rust!),
	# so we have to give it special treatment as well.
	home.file.".vim/bundle/sg.nvim/dist" = {
		recursive = true;
		source = pkgs.runCommandLocal "sourcegraph-sg.nvim-patched" {
			nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
		} ''
			mkdir -p $out
			cp -r ${sources.sgNvimBinaries.${pkgs.system}}/sg-* $out
			chmod -R 777 $out
			ls -la
		'';
	};
}
