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
		set -e

		region=( -g "$(slurp)" ) || region=()
		wf-recorder \
			-c h264_vaapi -d /dev/dri/renderD128 --bframes 0 \
			-f "screenrec_$(date +"%Y-%m-%d_%H:%M:%S").mp4"  \
			"''${region[@]}" "$@"
	'' (with pkgs; [ wf-recorder slurp ]);

	screengif = utils.writeBashScriptBin "screengif" ''
		set -e
		src="$PWD"
		dir="$(mktemp -d)"

		cleanup() { command rm -rf "$dir" }
		trap cleanup EXIT

		cd "$dir"
		${screenrec}/bin/screenrec

		files=( screenrec_*.mp4 )
		file="''${files[0]}"
		name="''${file%%.*}"

		ffmpeg -threads 8 -i "$file" -vf 'minterpolate=fps=50:mi_mode=blend' "frame%10d.png"
		gifski --fps 50 -o "$name.gif" "frame"*.png
	'';

	autostart = utils.writeBashScript "wayfire-autostart" ''
		set +e
		fork() { $@ & disown; }

		echo Forking...

		fork dex -a -s /home/diamond/.config/autostart/
		fork ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
		fork ${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr
		fork wlsunset -l 33.8 -L -117.9
		fork wf-background
		fork fcitx
		fork mako

		echo Forked everything.
	'' [];

in {
	pam.sessionVariables.XDG_CURRENT_DESKTOP = "Wayfire";

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
			"seattle-docked".outputs = [
				(enable "eDP-1" {
					mode     = "1920x1200@60.020000";
					position = "0,329";
					scale    = 1.2;
				})
				(enable "Unknown VP525" {
					mode     = "1920x1080@60.000000";
					position = "1600,0";
					scale    = 1.0;
				})
			];
			"normal".outputs = [
				(enable "eDP-1" {
					mode     = "1920x1200@60.020000";
					position = "0,0";
					scale    = 1.15;
				})
			];
		};
		systemdTarget = "wayfire-session.target";
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
		"wayfire.ini" = {
			source = pkgs.substituteAll {
				src = ./wayfire.ini;
				scrot = "${scrot}/bin/scrot.sh";
				autostart = autostart;
				polkit_gnome = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
			};
		};
		"wf-shell.ini" = {
			source = pkgs.substituteAll {
				src = ./wf-panel/wf-shell.ini;
				css = ./wf-panel/wf-panel.css;
				scrot = "${scrot}/bin/scrot.sh";
				menu_icon = ./wf-panel/menu.png;
			};
		};
	};

	systemd.user.targets.wayfire-session = {
		Unit = {
			Description = "wayfire compositor session";
			BindsTo = [ "graphical-session.target" ];
			Wants = [ "graphical-session-pre.target" ];
			After = [ "graphical-session-pre.target" ];
		};
	};
}
