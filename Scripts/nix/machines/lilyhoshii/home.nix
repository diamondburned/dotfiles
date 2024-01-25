{ config, lib, pkgs, ... }:

{
	home-manager.users.diamond = {
		imports = [
			<dotfiles/cfg/firefox>
			<dotfiles/cfg/zellij/home.nix>
			<dotfiles/cfg/fonts/home.nix>
			<dotfiles/cfg/gnome/home.nix>
			<dotfiles/cfg/nvim/home.nix>
			<dotfiles/cfg/foot/home.nix>
			<dotfiles/cfg/git/home.nix>
			<dotfiles/cfg/gtk/home.nix>
			<dotfiles/cfg/hm-gnome-terminal.nix>
			./cfg/firefox/home.nix
		];

		nixpkgs.config.allowUnfree = true;

		programs.direnv = {
			enable = true;
			config.load_dotenv = false;
			nix-direnv.enable = true;
		};

		programs.bash = {
			enable = true;
			initExtra = builtins.readFile <dotfiles/cfg/bashrc>;
		};

		gtk = {
			enable = true;
			# font.name = "Sans";
			font.size = 11;
		};

		programs.mpv = {
			enable = true;
			config = {
				osd-font = "Sans";
				osd-status-msg = "\${playback-time/full} / \${duration} (\${percent-pos}%)\\nframe: \${estimated-frame-number} / \${estimated-frame-count}";
				gpu-api = "auto";
				gpu-context = "auto";
				vo = "gpu";
				dither-depth = 8;
				scale = "lanczos";
				script-opts = "ytdl_hook-ytdl_path=yt-dlp";
			};
		};

		services.easyeffects.enable = true;

		home.packages = with pkgs; [
			celluloid
			chromium
			fcitx5-configtool
			fcitx5-gtk
			foot # TODO mgirate to HM
			gcolor3
			gimp
			git-crypt
			gnome.gnome-disk-utility
			gnome.gnome-power-manager
			gnome.gnome-tweaks
			go
			gopls
			gotab
			gtkcord4
			jq
			keepassxc
			komikku
			nix-output-monitor
			oxfs
			pavucontrol
			playerctl
			qalculate-gtk
			silver-searcher
			virt-manager
			waypipe
			wl-clipboard
			# libreoffice-fresh

			(callPackage ./packages/spot-git.nix {})
		];
		home.stateVersion = "23.11";

		fonts.fontconfig.enable = true;

		xdg = {
			enable = true;
			mime.enable = true;
			configFile = {
				"nixpkgs/config.nix".text = "{ allowUnfree = true; }";
			};
		};
	};
}
