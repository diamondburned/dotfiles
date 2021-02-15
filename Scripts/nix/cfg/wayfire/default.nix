{ config, lib, pkgs, ... }: 

let waylandPkgs  = import ./pkgs.nix { inherit lib pkgs; };
	utils   = import ../../utils.nix { inherit lib pkgs; };

	# autostart = utils.writeBashScript "autostart.sh" ''
	# 	# Essentials
	# 	dbus-update-activation-environment --all --systemd
	# 	dex -a &
	# 	# ${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr &

	# 	# Userspace Utilities
	# 	wf-panel &
	# 	wf-background &
	# 	wlsunset -l 33.8 -L -117.9 &
	# 	mako &

	# '' (
	# 	with waylandPkgs; [

	# 	]
	# );

	scrot = utils.writeBashScript "scrot.sh" ''
		export WAYLAND_DISPLAY=wayland-1

		slurp() {
			command slurp -w 1 -b '#00000000' -c '#FFFFFFFF' -s '#00000000'
		}

		[[ $1 == -a ]] && \
			{ slurp | grim -g - -c - | wl-copy; } || \
			{ grim -t jpeg -q 100 -  | wl-copy; }

		echo "Executed on $(date)."
	'' (
		with pkgs; [ slurp grim wl-clipboard ]
	);

in {
	# I hate GDM; it doesn't work. Use a dummy display manager.
	services.xserver.displayManager = {
		gdm = {
			enable  = true;
			wayland = true;
		};
		defaultSession  = "wayfire";
		sessionPackages = with waylandPkgs; [
			wayfire
		];
	};

	nix.binaryCachePublicKeys = [
		"nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
	];
	nix.binaryCaches = [
		"https://nixpkgs-wayland.cachix.org"
	];

	xdg.portal.extraPortals = with pkgs; [
		xdg-desktop-portal-wlr
		xdg-desktop-portal-gtk
	];
	xdg.portal.gtkUsePortal = true;

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
			dex
			dbus
			mako
			wlsunset

		] ++ (with waylandPkgs; [
			wlogout
		]);

		# programs.bash.profileExtra = ''
		# 	[[ ! $WAYLAND_DISPLAY && $- = *i* && $(tty) = /dev/tty1 ]] && {
		# 		# Add binutils for addr2line.
		# 		PATH="${pkgs.binutils}/bin:$PATH"
	
		# 		if [[ "$DBUS_SESSION_BUS_ADDRESS" ]]; then
		# 			exec wayfire &> /tmp/wayfire.log
		# 		else
		# 			exec dbus-launch --exit-with-session wayfire &> /tmp/wayfire.log
		# 		fi
		# 	}

		# 	[[ $WAYLAND_DISPLAY && $(ps aux) != *"wf-panel"* ]] && {
		# 		nautilus --gapplication-service &> /dev/null & disown
		# 		# wf-panel &> /tmp/autostart-wf-panel.log      & disown
		# 	}
		# '';

		xdg.configFile = {
			"wayfire.ini" = {
				source = pkgs.substituteAll {
					src = ./wayfire.ini;
					inherit scrot;
				};
			};
			"wf-shell.ini" = {
				source = pkgs.substituteAll {
					src = ./wf-shell.ini;
					css = ./wf-panel.css;
					menu_icon = ./menu.png;

					inherit scrot;
				};
			};
		};

		services.kanshi = {
			enable = true;
			profiles = with import ./kanshi.nix; {
				"docked".outputs = [
					(disable "eDP-1")
					(enable "Acer Technologies V277U TDCAA002852A" {
						position = "0,0";
						mode     = "2560x1440@69.928001";
					})
				];
				"normal".outputs = [
					(enable "eDP-1" {})
				];
			};
		};

		programs.mako = let f = ''<b>%s</b>\n%b''; in {
			enable   = true;
			font     = "Sans 11";
			anchor   = "top-center";
			format   = f;
			width    = 400;
			borderSize = 2;
			defaultTimeout = 10000;
			iconPath = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
			groupBy  = "app-name";
			extraConfig = 
				"[grouped]\n" +
				"format=\"${f}\"";
		};
	};

	services.xserver.enable  = true;
	programs.xwayland.enable = true;
}
