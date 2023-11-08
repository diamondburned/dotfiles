{ config, lib, pkgs, ... }:

{
	home-manager.users.diamond = {
		imports = [
			<dotfiles/cfg/firefox>
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
			font.name = "Sans";
			font.size = 11;
		};

		services.easyeffects.enable = true;

		home.packages = with pkgs; [
			keepassxc
			fcitx5-configtool
			fcitx5-gtk
			wl-clipboard
			playerctl
			waypipe
			celluloid
			oxfs
			foot # TODO mgirate to HM
			virt-manager
			zellij
			gtkcord4
			silver-searcher
			pavucontrol
			nix-output-monitor
			jq
			go
			gopls
			gotab
			gnome.gnome-tweaks
			gnome.gnome-disk-utility
			gnome.gnome-power-manager
			gcolor3
			gimp
			git-crypt
			qalculate-gtk
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
