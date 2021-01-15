{ config, lib, pkgs, ... }:

let waylandPkgs = import ./waylandpkgs.nix;
	utils = import ../../utils.nix { inherit lib pkgs; };

	autostart = utils.writeBashScript "autostart.sh" ''
		dex -a
		wlsunset -l 33.8 -L -117.9 &
		mako &

	'' (with pkgs; [
		dex
		dbus
		mako
		kanshi
		wlsunset
	]);

	winscrot = utils.writeBashScript "winscrot.sh" ''
		monitor_sel="$(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')"
		window_sel="$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')"
		exec printf '%s\n' "$monitor_sel" "$window_sel" | slurp "$@"
	'' (with pkgs; [
		jq
		sway
		slurp
	]);

in {
	# Enable GDM.
	services.xserver = {
		enable = true;
		displayManager = {
			gdm.enable = true;
			defaultSession = "sway";
		};
	};

	programs.xwayland.enable = true;

	xdg.portal.extraPortals = with pkgs; [
		xdg-desktop-portal-wlr
	];

	nixpkgs.overlays = [ (import ./overlay.nix) ];

	programs.sway = {
		enable = true;
		wrapperFeatures.gtk = true;
		extraPackages = with pkgs; [
			polkit_gnome
		];
	};

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

		xdg.configFile = {
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
					(position "DP-2" "2392,655")
					(position "HDMI-A-1"  "0,0")
				];
				"normal".outputs = [
					(enable "eDP-1")
				];
			};
		};

		programs.mako = {
			enable = true;
		};

		wayland.windowManager.sway = {
			enable  = true;
			package = pkgs.sway;
			config = {
				input = {
					"type:keyboard" = {
						repeat_delay = "200";
						repeat_rate  = "50";
					};
					"type:pointer" = {
						middle_emulation = "enabled";
						accel_profile = "flat";
						pointer_accel = "0.25";
					};
					"type:touchpad" = {
						natural_scroll = "enabled";
						scroll_method = "two_finger";
						tap = "enabled";
						tap_button_map = "lrm";
					};
				};
				output = {
					"*".bg = "${../../background.jpg} fill";
					"Acer Technologies SB220Q 0x0000DACC" = { # DP-2
						mode = "1920x1080@74.973Hz";
						subpixel = "rgb";
					};
					"Acer Technologies V277U TDCAA002852A" = { # HDMI-A-0
						mode  = "2560x1440@69.928Hz";
						scale = "1.07";
						subpixel = "none";
						max_render_time = "12";
					};
				};
				modifier = "Mod4"; # Super
				floating = {
					border = 0;
					criteria = [ { title = "."; } ]; # all windows
					modifier = "Mod4";
					titlebar = true;
				};
				colors = {};
				focus = {
					followMouse  = false;
					mouseWarping = false;
				};
				fonts = [ "Sans 11" ];
				bars  = [];
				menu  = "wofi --show drun";
				keybindings = {
					# Launchers
					"Mod4" = "exec wofi --show drun";
					# Alt+Tab
					"Mod1+Tab"    = "focus next";
					"Mod1+Escape" = "focus prev";
					# Screenshooting
					"Print"       =   "exec grim -t jpeg -s 1 -q 100 - | wl-copy";
					"Alt+Print" = "exec ${winscrot} | grim -s 1 -g - - | wl-copy";
					"Shift+Print" =     "exec slurp | grim -s 1 -g - - | wl-copy";
					# Media
					"XF86AudioPlay" = "exec playerctl play-pause";
					"XF86AudioNext" = "exec playerctl next";
					"XF86AudioPrev" = "exec playerctl previous";
					"XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +2%";
					"XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -2%";
					"XF86AudioMute"        = "exec pactl set-sink-mute   @DEFAULT_SINK@ toggle";
				};
				startup = [ { command = "${autostart}"; } ];
				terminal = "gnome-terminal";
				window = {
					border = 0;
					titlebar = true;
					hideEdgeBorders = "smart";
					commands = let all = command: { inherit command; criteria.title = "."; }; in [
						(all ''title_format "<b>%title</b>"'')
						(all ''border csd'')
					];
				};
			};
			xwayland = true;
			wrapperFeatures.gtk = true;
			extraSessionCommands = "";
			extraConfig = ''
				seat seat0 {
					xcursor_theme Ardoise_shadow_87 52
				}

				floating_maximum_size -1 x -1
				raise_floating yes

				titlebar_border_thickness 0
				titlebar_padding 0
			'';
		};
	};
}
