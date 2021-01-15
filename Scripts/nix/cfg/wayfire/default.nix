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

	scrot = utils.writeBashScript "scrot.sh" ''
		export WAYLAND_DISPLAY=wayland-1

		[[ $1 == -a ]] && \
			{ slurp | grim -g - -c - | wl-copy; } || \
			{ grim -t jpeg -q 100 -  | wl-copy; }

		echo "Executed on $(date)."
	'' (
		with pkgs; [ slurp grim wl-clipboard ]
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

	xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];

	nixpkgs.overlays = [ (import ./overlay.nix) ];

	environment.systemPackages = with waylandPkgs; [
		wayfire
		polkit_gnome
	];

	home-manager.users.diamond = {
		home.packages = with pkgs; [
			slurp
			grim
			wofi
			playerctl
			wl-clipboard
			wf-shell

		] ++ (with waylandPkgs; [
			wlogout
		]);

		programs.bash.profileExtra = ''
			[[ ! $WAYLAND_DISPLAY && $- = *i* && $(tty) = /dev/tty1 ]] && {
				# Add binutils for addr2line.
				PATH="${pkgs.binutils}/bin:$PATH"
	
				exec dbus-run-session wayfire &> /tmp/wayfire.log
			}

			[[ $WAYLAND_DISPLAY && $(ps aux) != *"wf-panel"* ]] && {
				nautilus --gapplication-service &> /dev/null & disown
				wf-panel &> /tmp/autostart-wf-panel.log      & disown
			}
		'';

		xdg.configFile = {
			"wayfire.ini" = {
				source = pkgs.substituteAll {
					src = ./wayfire.ini;
					autostart = "${autostart}";

					inherit scrot;
				};
			};
			"wf-shell.ini" = {
				source = pkgs.substituteAll {
					src = ./wf-shell.ini;
					css = ./wf-panel.css;
					menu_icon = ./menu.png;
				};
			};
		};

		services.kanshi = {
			enable = true;
			profiles = with import ./kanshi.nix; {
				"docked".outputs = [
					(disable  "eDP-1")
					(position "Acer Technologies V277U TDCAA002852A"  "0,0"      1.07)
					(position "Acer Technologies SB220Q 0x0000DACC"   "2392,655" 1.00)
				];
				"normal".outputs = [
					(enable "eDP-1")
				];
			};
		};

		programs.mako = {
			enable = true;
		};
	};

	services.xserver.enable  = true;
	programs.xwayland.enable = true;
}
