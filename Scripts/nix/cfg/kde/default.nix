{ config, lib, pkgs, ... }:

# https://nixos.wiki/wiki/KDE
{
	services.xserver.enable = true;
	services.xserver.desktopManager.plasma5.enable = true;

	environment.plasma5.excludePackages = with pkgs.libsForQt5; [
	  elisa
	  gwenview
	  okular
	  oxygen
	  khelpcenter
	  konsole
	  print-manager
	];

	programs.dconf.enable = true;
	services.xserver.displayManager.defaultSession = "plasmawayland";

	# Keep GNOME's Askpass. Plasma5 doesn't have an option to not override.
	programs.ssh.askPassword = "${pkgs.gnome.seahorse}/libexec/seahorse/ssh-askpass";
}
