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

	autostart = utils.writeBashScript "wayfire-autostart" ''
		set +e
		fork() { $@ & disown; }

		echo Forking...

		fork dex -a -s /home/diamond/.config/autostart/
		fork ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
		fork ${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr
		fork wlsunset -l 33.8 -L -117.9
		fork wf-background
		fork wf-panel
		fork fcitx
		fork mako

		echo Forked everything.
	'' [];

in {
	wayland.windowManager.sway = {
		enable = true;
		config = {
			modifier = "Mod4";
			# colors = {
			# 	background  = "#1d1d1d";
			# 	text        = "#eeeeee";
			# 	border      = "#2e2e2e";
			# 	indicator   = "#5294e2";
			# 	childBorder = "#2e2e2e";
			# };
			floating = {
				border   = 0;
				titlebar = true;
				criteria = [
					{ class  = ".*"; }
					{ app_id = ".*"; }
				];
			};
			focus = {
				followMouse  = "no";
				mouseWarping = false;
			};
			fonts = {
				names = [ "Sans" ];
				size  = 11.5;
			};
			bars = [];
			input = {
				"type:keyboard" = {
					repeat_delay = "200";
					repeat_rate  = "50";
					xkb_options  = "caps:escape";
				};
				"*" = {
					middle_emulation = "true";
				};
				"type:pointer" = {
					accel_profile = "flat";
					pointer_accel = "0.1";
				};
				"type:touchpad" = {
					click_method     = "clickfinger";
					scroll_method    = "two_finger";
					natural_scroll   = "true";
					drag             = "true";
					tap              = "true";
				};
			};
			keybindings =
				let mod = config.wayland.windowManager.sway.config.modifier;
					alt = "Mod1";
				in lib.mkOptionDefault {
					"Print"       = "exec scrot.sh";
					"Shift+Print" = "exec scrot.sh -a";

					"XF86AudioPlay" = "exec playerctl play-pause";
					"XF86AudioNext" = "exec playerctl next";
					"XF86AudioPrev" = "exec playerctl previous";

					"XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +2%";
					"XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -2%";
					"XF86AudioMute"        = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";

					"${mod}+Tab"       = "scratchpad show";
					"${alt}+Tab"       = "focus next";
					"${alt}+Shift+Tab" = "focus prev";
				};
				keycodebindings = {
					"274" = "move scratchpad"; # Secondary
					"275" = "kill";            # Middle
				};
			menu     = "gappdash";
			terminal = "gnome-terminal";
			startup  = [ { command = "${autostart}"; } ];
			window   = {
				titlebar = true;
			};
			output = {
				"Acer Technologies V277U TDCAA002852A" = {
					adaptive_sync = "on";
				};
			};
		};
		extraSessionCommands = ''
			dbus-update-activation-environment --all --systemd
			systemctl --user import-environment
		'';
		swaynag = {
			enable = true;
		};
		wrapperFeatures = {
			gtk  = true;
			base = true;
		};
	};

	nixpkgs.overlays = [
		(import ./overlay.nix)
	];

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
	];

	services.kanshi = {
		enable = true;
		profiles = with import ./kanshi.nix; {
			"docked".outputs = [
				(disable "eDP-1")
				(enable "Acer Technologies V277U TDCAA002852A" {
					position = "1037,1268";
					mode     = "2560x1440@69.928001";
					scale    = 1.0;
				})
				(enable "Unknown Sceptre F24 0x00000001" {
					position = "1168,0";
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

	xdg.configFile = {
		"wf-shell.ini" = {
			source = pkgs.substituteAll {
				src = ./wf-panel/wf-shell.ini;
				css = ./wf-panel/wf-panel.css;
				scrot = "${scrot}/bin/scrot.sh";
				menu_icon = ./wf-panel/menu.png;
			};
		};
	};
}
