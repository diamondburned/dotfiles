self: super:

with builtins;
with super.lib;

let
	nixpkgs_gnome = import <nixpkgs_gnome> {};
	nixpkgs = import <nixpkgs> {
		overlays = [
			(self: super: {
				gtk4 = super.callPackage <nixpkgs_gnome/pkgs/development/libraries/gtk/4.x.nix> {
					AppKit = null;
					Cocoa = null;
				};
				glib = super.callPackage <nixpkgs_gnome/pkgs/development/libraries/glib> {};
				gnome-tecla = self.callPackage <nixpkgs_gnome/pkgs/applications/misc/gnome-tecla/default.nix> {};
			})
			(self: super: (unfuckPkgs {
				adwaita-icon-theme = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/adwaita-icon-theme> {};
				gdm = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gdm> {};
				gnome-backgrounds = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-backgrounds> {};
				gnome-bluetooth = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-bluetooth> {};
				gnome-color-manager = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-color-manager> {};
				gnome-control-center = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-control-center> {};
				gnome-common = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-common> {};
				gnome-disk-utility = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-disk-utility> {};
				gnome-keyring = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-keyring> {};
				libgnome-keyring = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/libgnome-keyring> {};
				gnome-online-miners = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-online-miners> {};
				gnome-remote-desktop = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-remote-desktop> {};
				gnome-session = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-session> {};
				gnome-session-ctl = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-session/ctl.nix> {};
				gnome-shell = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-shell> {};
				gnome-shell-extensions = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-shell-extensions> {};
				gnome-screenshot = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-screenshot> {};
				gnome-settings-daemon = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-settings-daemon> {};
				gnome-terminal = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-terminal> {};
				gnome-themes-extra = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-themes-extra> {};
				gnome-user-share = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/gnome-user-share> {};
				mutter = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/mutter> {};
				nautilus = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/core/nautilus> {};
				nixos-gsettings-overrides = self.callPackage <nixpkgs_gnome/pkgs/desktops/gnome/nixos/gsettings-overrides> {};
			}))
		];
	};

	unfuckPkgs = pkgs: mapAttrs
		(_: pkg: pkg.overrideAttrs (_: { doCheck = false; }))
		(pkgs);

	pkgPath = pkg: builtins.head (builtins.split ":" (pkg.meta.position));
in

{
	gnome = super.gnome.overrideScope' (gnomeself: gnomesuper: {
		inherit (nixpkgs.gnome)
			adwaita-icon-theme
			gdm
			gnome-backgrounds
			gnome-bluetooth
			gnome-color-manager
			gnome-control-center
			gnome-common
			gnome-disk-utility
			gnome-keyring
			libgnome-keyring
			gnome-online-miners
			gnome-remote-desktop
			gnome-session
			gnome-session-ctl
			gnome-shell
			gnome-shell-extensions
			gnome-screenshot
			gnome-settings-daemon
			gnome-terminal
			gnome-themes-extra
			gnome-user-share
			mutter
			nautilus
			nixos-gsettings-overrides;
	});

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
}
