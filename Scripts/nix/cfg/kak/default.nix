{ config, lib, pkgs, ... }:

{
	programs.kakoune = {
		enable = false;
		config = {
			alignWithTabs = true;
			autoComplete = [ "prompt" "insert" ];
			autoInfo = [ "command" "onkey" "normal" ];
			autoReload = "yes";
			indentWidth = 0;
			keyMappings =
				let k = mode: key: effect: { inherit mode key effect; };
					view = key: effect: k "view" key effect;
					goto = key: effect: k "goto" key effect;
					user = key: effect: k "user" key effect;
					menu = key: effect: k "menu" key effect;
					prompt = key: effect: k "prompt" key effect;
					normal = key: effect: k "normal" key effect;
					insert = key: effect: k "insert" key effect;
				in [
					(view "<c-c>" "y")
					(normal "P" "!wl-paste<ret>")
					(normal "p" "<a-!>wl-paste<ret>")
				];
			hooks = [
				{
					name = "NormalKey";
					option = "y|d|c|<c-c>";
					commands = ''
						nop %sh {
							printf "%s" "$kak_main_reg_dquote" \
								| wl-copy > /dev/null 2>&1 &
						}
					'';
				}
			];
			numberLines = {
				enable = true;
				separator = "▏";
				highlightCursor = true;
			};
			scrollOff = { lines = 10; };
			showMatching = true;
			ui = {
				enableMouse = true;
				assistant = "clippy";
				changeColors = false;
				setTitle = true;
			};
		};
		# plugins = with pkgs.kakounePlugins; [
		# 	kak-auto-pairs
		# 	kak-buffers

		# 	pkgs.kak-lsp

		# 	(pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
		# 		pname = "kaktree";
		# 		version = "latest-1";
		# 		src = builtins.fetchGit {
		# 			url = "https://github.com/andreyorst/kaktree.git";
		# 			ref = "master";
		# 		};
		# 		buildInputs = with pkgs; [ perl ];
		# 	})

		# 	(pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
		# 		pname = "kakoune-smooth-scroll";
		# 		version = "latest-1";
		# 		src = builtins.fetchGit {
		# 			url = "https://github.com/caksoylar/kakoune-smooth-scroll.git";
		# 			ref = "master";
		# 		};
		# 		buildInputs = with pkgs; [ python ];
		# 	})

		# 	(pkgs.kakouneUtils.buildKakounePluginFrom2Nix {
		# 		pname = "plug.kak";
		# 		version = "latest-1";
		# 		src = builtins.fetchGit {
		# 			url = "https://github.com/andreyorst/plug.kak.git";
		# 			ref = "master";
		# 		};
		# 		buildInputs = with pkgs; [ bash coreutils ];
		# 	})
		# ];
		extraConfig = builtins.readFile ./kakrc;
	};
}
