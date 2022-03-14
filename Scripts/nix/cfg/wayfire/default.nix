{ config, lib, pkgs, ... }: 

let utils = import ../../utils { inherit config lib pkgs; };

	scrot = utils.writeBashScriptBin "scrot.sh" ''
		export WAYLAND_DISPLAY=wayland-1

		slurp() {
			command slurp -w 0 -b '#00000088' -s '#00000000'
		}

		[[ $1 == -a ]] && \
			{ slurp | grim -g - -c - | wl-copy; } || \
			{ grim -t jpeg -q 100 -  | wl-copy; }

		echo "Executed on $(date)."
	'' (with pkgs; [ slurp grim wl-clipboard ]);

	screenrec = utils.writeBashScriptBin "screenrec" ''
		region=( -g "$(slurp)" ) || region=()
		wf-recorder \
			-c h264_vaapi -d /dev/dri/renderD128 --bframes 0 \
			-f "screenrec_$(date +"%Y-%m-%d_%H:%M:%S").mp4"  \
			"''${region[@]}" "$@"
	'' (with pkgs; [ wf-recorder slurp ]);

in {
	services.xserver.displayManager = {
		gdm = {
			enable  = true;
			wayland = true;
		};
		# lightdm.greeters.gtk = {
		# 	enable = true;
		# 	iconTheme = {
		# 		package = pkgs.papirus-icon-theme;
		# 		name    = "Papirus-Dark";
		# 	};
		# 	theme = {
		# 		package = pkgs.materia-theme;
		# 		name    = "Materia-dark-compact";
		# 	};
		# 	extraConfig = ''
		# 		[greeter]
		# 		background=${../../background.jpg}
		# 		active-monitor=0
		# 		position=75%,center 50%,center
		# 	'';
		# };
		# defaultSession = "gnome";
		sessionPackages = with pkgs; [
			wayfire-session
			# labwc-session
		];
	};

# 	# I hate GDM; it drags in dumb build dependencies. Use a dummy display
# 	# manager.
# 	services.xserver.displayManager.startx.enable = true;

	nix.binaryCachePublicKeys = [
		"nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
	];
	nix.binaryCaches = [
		"https://nixpkgs-wayland.cachix.org"
	];

	xdg.portal = {
		# GNOME has their own portal.
		enable = true;
		extraPortals = with pkgs; [
			xdg-desktop-portal-wlr
			# xdg-desktop-portal-gtk
		];
		gtkUsePortal = true;
	};

	# xdg.portal = {
	# 	enable = true;
	# 	extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
	# 	# gtkUsePortal = false;
	# };

	nixpkgs.overlays = [ (import ./overlay.nix) ];

	# Extracted from Unstable's programs.xwayland.
	environment.pathsToLink = [
		"/share/X11"
		"/libexec" # polkit
	];

	environment.systemPackages = with pkgs; [
		# labwc
		# labwc-session
		wayfire
		wayfire-session
		polkit_gnome
	];

	home-manager.users.diamond = {
		pam.sessionVariables.XDG_CURRENT_DESKTOP = "Wayfire";

		home.packages = with pkgs; [
			scrot
			slurp
			grim
			wofi
			playerctl
			wl-clipboard
			wf-shell
			wf-recorder
			screenrec
			kanshi
			dex
			dbus
			mako
			wlsunset
			wlogout
			gappdash
		];

		programs.bash.profileExtra = ''
			# [[ ! $WAYLAND_DISPLAY && $- = *i* && $(tty) = /dev/tty1 ]] && {
			# 	# Add binutils for addr2line.
			# 	PATH="${pkgs.binutils}/bin:$PATH"
			#
			# 	if [[ "$DBUS_SESSION_BUS_ADDRESS" ]]; then
			# 		exec wayfire &> /tmp/wayfire.log
			# 	else
			# 		exec dbus-launch --exit-with-session wayfire &> /tmp/wayfire.log
			# 	fi
			# }

			[[ $WAYLAND_DISPLAY && $(ps aux) != *"nautilus"* ]] && {
				nautilus --gapplication-service &> /dev/null & disown
			}
		'';

		xdg.configFile = {
			"wayfire.ini" = {
				source = pkgs.substituteAll {
					src = ./wayfire.ini;
					scrot = "${scrot}/bin/scrot.sh";
					polkit_gnome = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
				};
			};
			"wf-shell.ini" = {
				source = pkgs.substituteAll {
					src = ./wf-shell.ini;
					css = ./wf-panel.css;
					scrot = "${scrot}/bin/scrot.sh";
					menu_icon = ./menu.png;
				};
			};
		};

		services.kanshi = {
			enable = true;
			profiles = with import ./kanshi.nix; {
				"docked".outputs = [
					(disable "eDP-1")
					(enable "Acer Technologies V277U TDCAA002852A" {
						position = "0,1270";
						mode     = "2560x1440@69.928001";
						scale    = 1.0;
					})
					(enable "Unknown Sceptre F24 0x00000001" {
						position = "151,0";
						mode     = "1920x1080@74.973000";
						scale    = 0.85;
					})
				];
				"normal".outputs = [
					(enable "eDP-1" {
						mode     = "1920x1080@60.020000";
						position = "0,0";
						scale    = 1.2;
					})
				];
			};
		};

		programs.mako = {
			enable   = true;
			font     = "Sans 11";
			anchor   = "top-center";
			format   = "<b>%s</b>\\n%b";
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
