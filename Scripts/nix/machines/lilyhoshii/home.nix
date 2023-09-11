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
			foot # TODO mgirate to HM
			gtkcord4
			silver-searcher
			pavucontrol
			go
			gopls
			gnome.gnome-tweaks
			gnome.gnome-disk-utility
			gnome.gnome-power-manager
			qalculate-gtk
		];
		home.stateVersion = "23.11";

		fonts.fontconfig.enable = true;
	};

}
