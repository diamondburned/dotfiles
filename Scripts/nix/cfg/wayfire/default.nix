{ config, lib, pkgs, ... }: 

let waylandPkgs  = import ./pkgs.nix { inherit lib pkgs; };
	utils   = import ../../utils.nix { inherit lib pkgs; };

	autostart = utils.writeBashScript "autostart.sh" ''
		# Essentials
		dbus-update-activation-environment --all
		dex -a
		${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr &

		# Userspace Utilities
		wf-background &
		wf-panel &
		wlsunset -l 33.8 -L -117.9 &
		kanshi &
		mako &

	'' (
		with waylandPkgs; [
			dex
			dbus
			mako
			kanshi
			wlsunset
		]
	);

in {
	# I hate GDM; it doesn't work. Use a dummy display manager.
	services.xserver.displayManager.startx.enable = true;

	nix.binaryCachePublicKeys = [
		"nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
	];
	nix.binaryCaches = [
		"https://nixpkgs-wayland.cachix.org"
	];

	environment.systemPackages = with waylandPkgs; [
		wayfire
		polkit_gnome
	];

	home-manager.users.diamond.home.packages = with waylandPkgs; [
		slurp
		grim
		wofi
		playerctl
		wl-clipboard
		wf-shell
		wlogout
	];

	home-manager.users.diamond.programs.bash.profileExtra = ''
		[[ $- = *i* && $(tty) = /dev/tty1 ]] && {
			# Add binutils for addr2line.
			PATH="${pkgs.binutils}/bin:$PATH"

			exec dbus-run-session wayfire &> /tmp/wayfire.log
		}
	'';



	xdg.portal.extraPortals = with waylandPkgs; [ xdg-desktop-portal-wlr ];

	services.xserver.enable  = true;
	programs.xwayland.enable = true;
}
