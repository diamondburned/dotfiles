{ config, lib, pkgs, ... }:

let
	sg_nvim = pkgs.runCommandLocal
		"sourcegraph-sg.nvim-patched"
		(rec {
			passthru.binaries = {
				x86_64-linux = pkgs.fetchzip {
					url = "https://github.com/sourcegraph/sg.nvim/releases/download/v1.0.8/sg-x86_64-unknown-linux-gnu.tar.xz";
					sha256 = "sha256-lbimCt+YbE2oJlKma/SyL/BVa4c132IzVOL/W6ofh7Y=";
				};
				aarch64-linux = pkgs.fetchzip {
					url = "https://github.com/sourcegraph/sg.nvim/releases/download/v1.0.8/sg-aarch64-unknown-linux-gnu.tar.xz";
					sha256 = "";
				};
			};
			nativeBinary = pkgs.autoPatchelf {
				pkg = passthru.binaries.${pkgs.system};
				buildInputs = with pkgs; [ libgcc ];
			};
		})
		''
			mkdir -p $out/bin
			cp -ra --no-preserve=mode $nativeBinary/sg-* $out/bin/
			chmod +x $out/bin/*
		'';
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
		sg_nvim
	];
}
