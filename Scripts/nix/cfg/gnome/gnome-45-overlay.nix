self: super:

let
	nixpkgs_gnome = import <nixpkgs_gnome> {};
in

{
	# Override with GNOME 45 builds.
	gnome = super.gnome.overrideScope' (gnomeself: gnomesuper: {
		inherit (nixpkgs_gnome.gnome)
			adwaita-icon-theme
			baobab
			dconf-editor
			evince
			gdm
			gnome-backgrounds
			gnome-bluetooth
			gnome-color-manager
			gnome-contacts
			gnome-control-center
			gnome-calculator
			gnome-common
			gnome-dictionary
			gnome-disk-utility
			gnome-font-viewer
			gnome-keyring
			gnome-initial-setup
			gnome-online-miners
			gnome-remote-desktop
			gnome-session
			gnome-session-ctl
			gnome-shell
			gnome-shell-extensions
			gnome-screenshot
			gnome-settings-daemon
			gnome-software
			gnome-system-monitor
			gnome-terminal
			gnome-themes-extra
			gnome-user-share
			gucharmap
			eog
			mutter
			nautilus;
	});
}
