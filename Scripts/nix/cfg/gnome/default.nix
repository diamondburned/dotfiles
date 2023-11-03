{ config, lib, pkgs, ... }:

{
	# Enable the GNOME desktop environment
	services.xserver.desktopManager.gnome.enable = true;

	# Enable GDM.
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.displayManager.gdm.autoSuspend = true;

	# More GNOME things
	services.gnome = {
		core-shell.enable = true;
		core-os-services.enable = true;
		gnome-settings-daemon.enable = true;
		core-utilities.enable = true;

		# Enable the Keyring for password managing
		gnome-keyring.enable = true;

		# Online stuff
		gnome-user-share.enable = true;
		gnome-online-accounts.enable = true;
		gnome-online-miners.enable = true;
		gnome-browser-connector.enable = true;

		# Disable garbage
		tracker.enable = false;
		tracker-miners.enable = false;
		gnome-initial-setup.enable = false;
	};

	environment.gnome.excludePackages = with pkgs; with pkgs.gnome; [
		gnome-contacts
		gnome-initial-setup
		gnome-calendar
		gnome-console
		epiphany
		yelp
		geary
		totem
		cheese
		tracker-miners
		sushi
		gnome-photos
		gnome-music
	];

	programs.kdeconnect = {
		enable  = true;
		package = pkgs.gnomeExtensions.gsconnect;
	};
}
