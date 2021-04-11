{ config, lib, pkgs, ... }: 

let utils = import ../../utils.nix { inherit lib pkgs; };

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
	# services.xserver.displayManager = {
	# 	gdm = {
	# 		enable  = true;
	# 		wayland = true;
	# 	};
	# 	defaultSession  = "wayfire";
	# 	sessionPackages = with pkgs; [ wayfire ];
	# };

	# I hate GDM; it drags in dumb build dependencies. Use a dummy display
	# manager.
	services.xserver.displayManager.startx.enable = true;

	nix.binaryCachePublicKeys = [
		"nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
	];
	nix.binaryCaches = [
		"https://nixpkgs-wayland.cachix.org"
	];

	xdg.portal.extraPortals = with pkgs; [
		xdg-desktop-portal-wlr
	];
	xdg.portal.gtkUsePortal = true;

	nixpkgs.overlays = [ (import ./overlay.nix) ];

	# Extracted from Unstable's programs.xwayland.
	environment.pathsToLink = [ "/share/X11" ];

	environment.systemPackages = with pkgs; [
		wayfire
		xwayland
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
			kanshi
			dex
			dbus
			mako
			wlsunset
			wlogout
		];

		programs.bash.profileExtra = ''
			[[ ! $WAYLAND_DISPLAY && $- = *i* && $(tty) = /dev/tty1 ]] && {
				# Add binutils for addr2line.
				PATH="${pkgs.binutils}/bin:$PATH"
	
				if [[ "$DBUS_SESSION_BUS_ADDRESS" ]]; then
					exec wayfire &> /tmp/wayfire.log
				else
					exec dbus-launch --exit-with-session wayfire &> /tmp/wayfire.log
				fi
			}

			[[ $WAYLAND_DISPLAY && $(ps aux) != *"nautilus"* ]] && {
				nautilus --gapplication-service &> /dev/null & disown
			}
		'';

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
					(enable "eDP-1" {
						scale = 1.2;
					})
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
			# extraConfig = 
			# 	"[grouped]\n" +
			# 	"format=\"${f}\"";
		};
	};

	services.xserver.enable  = true;
}
