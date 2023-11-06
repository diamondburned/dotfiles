self: super:

with builtins;
with super.lib;

let
	nixpkgs_gnome = import <nixpkgs_gnome> {};

	unfuckPkgs = pkgs: mapAttrs
		(_: pkg:
			((pkg.override { inherit (nixpkgs_gnome) glib; }).overrideAttrs (_: { doCheck = false; })))

		(pkgs);
in

{
	# Override with GNOME 45 builds.
	# gnome = super.gnome.overrideScope' (gnomeself: gnomesuper: {
	# 	inherit (nixpkgs_gnome.gnome)
	# 		adwaita-icon-theme
	# 		baobab
	# 		dconf-editor
	# 		evince
	# 		gdm
	# 		gnome-backgrounds
	# 		gnome-bluetooth
	# 		gnome-color-manager
	# 		gnome-contacts
	# 		gnome-control-center
	# 		gnome-calculator
	# 		gnome-common
	# 		gnome-dictionary
	# 		gnome-disk-utility
	# 		gnome-font-viewer
	# 		gnome-keyring
	# 		gnome-initial-setup
	# 		gnome-online-miners
	# 		gnome-remote-desktop
	# 		gnome-session
	# 		gnome-session-ctl
	# 		gnome-shell
	# 		gnome-shell-extensions
	# 		gnome-screenshot
	# 		gnome-settings-daemon
	# 		gnome-software
	# 		gnome-system-monitor
	# 		gnome-terminal
	# 		gnome-themes-extra
	# 		gnome-user-share
	# 		gucharmap
	# 		eog
	# 		mutter
	# 		nautilus;
	# });

	gnome = super.gnome.overrideScope (gnomeself: gnomesuper: (unfuckPkgs {
		adwaita-icon-theme = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/adwaita-icon-theme> {};
		gdm = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gdm> {};
		gnome-backgrounds = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-backgrounds> {};
		gnome-bluetooth = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-bluetooth> {};
		gnome-color-manager = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-color-manager> {};
		gnome-control-center = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-control-center> {};
		gnome-common = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-common> {};
		gnome-disk-utility = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-disk-utility> {};
		gnome-keyring = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-keyring> {};
		libgnome-keyring = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/libgnome-keyring> {};
		gnome-online-miners = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-online-miners> {};
		gnome-remote-desktop = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-remote-desktop> {};
		gnome-session = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-session> {};
		gnome-session-ctl = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-session/ctl.nix> {};
		gnome-shell = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-shell> {};
		gnome-shell-extensions = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-shell-extensions> {};
		gnome-screenshot = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-screenshot> {};
		gnome-settings-daemon = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-settings-daemon> {};
		gnome-terminal = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-terminal> {};
		gnome-themes-extra = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-themes-extra> {};
		gnome-user-share = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-user-share> {};
		mutter = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/mutter> {};
		nautilus = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/nautilus> {};
		nixos-gsettings-overrides = gnomeself.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/nixos/gsettings-overrides> {};

		inherit (nixpkgs_gnome)
			gnome-tecla;
	}));
}
