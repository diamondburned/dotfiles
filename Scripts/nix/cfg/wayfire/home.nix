{ config, lib, pkgs, ... }: 

with pkgs;
with pkgs.lib;

let
	utils = import ../../utils { inherit config lib pkgs; };

	scrot = writeShellApplication {
		name = "scrot";
		text = ''
			# export WAYLAND_DISPLAY=wayland-1
	
			slurp() {
				command slurp -w 0 -b '#00000088' -s '#00000000'
			}
	
			printf -v FILENAME "screenshot_%(%Y-%m-%d_%H:%M:%S)T.png"
			FILEPATH="$HOME/Pictures/Screenshots/$FILENAME"
	
			{
				if [[ "$1" == -a ]]; then
					slurp | grim -g - -c -
				else
					grim -t jpeg -q 100 -
				fi
			} > "$FILEPATH"
	
			action=$(
				timeout 10s notify-send \
					-a scrot \
					-i image \
					-A 'open-folder=Open Folder' \
					"Screenshot Taken" \
					"Screenshot saved as $FILENAME."
			)
			if [[ "$action" == "open-folder" ]]; then
				xdg-open "$(dirname "$FILEPATH")"
			fi
		'';
		runtimeInputs = with pkgs; [
			slurp
			grim
			libnotify
			xdg-open
		];
	};

	screenrec = writeShellApplication {
		name = "screenrec";
		text = ''
			printf -v FILENAME "screenrec_%(%Y-%m-%d_%H:%M:%S)T.mp4"
			region=( -g "$(slurp)" ) || region=()
			wf-recorder \
				-c h264_vaapi -d /dev/dri/renderD128 --bframes 0 \
				-f "$HOME/Videos/$FILENAME" \
				"''${region[@]}" "$@"
		'';
		runtimeInputs = with pkgs; [
			wf-recorder
			slurp
		];
	};

	# screengif = utils.writeBashScriptBin "screengif" ''
	# 	set -e
	# 	src="$PWD"
	# 	dir="$(mktemp -d)"
	#
	# 	cleanup() { command rm -rf "$dir" }
	# 	trap cleanup EXIT
	#
	# 	cd "$dir"
	# 	${screenrec}/bin/screenrec
	#
	# 	files=( screenrec_*.mp4 )
	# 	file="''${files[0]}"
	# 	name="''${file%%.*}"
	#
	# 	ffmpeg -threads 8 -i "$file" -vf 'minterpolate=fps=50:mi_mode=blend' "frame%10d.png"
	# 	gifski --fps 50 -o "$name.gif" "frame"*.png
	# '';

in {
	pam.sessionVariables.XDG_CURRENT_DESKTOP = "Wayfire";

	nixpkgs.overlays = [
		(self: super: {
			inherit
				scrot
				screenrec;
		})
		# (import ./overlay.nix)
	];

	home.packages = with pkgs; [
		scrot
		slurp
		grim
		wofi
		playerctl
		wl-clipboard
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
		enable = false;
	};

	services.wlsunset = {
		enable = true;
		latitude = 33.8;
		longitude = -117.9;
	};

	# services.mako = {
	# 	enable   = true;
	# 	font     = "Sans 11";
	# 	anchor   = "top-center";
	# 	format   = "<b>%s<dotfiles/b>\\n%b";
	# 	width    = 400;
	# 	borderSize = 2;
	# 	defaultTimeout = 10000;
	# 	iconPath = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark";
	# 	groupBy  = "app-name";
	# 	# extraConfig = 
	# 	# 	"[grouped]\n" +
	# 	# 	"format=\"${f}\"";
	# };

	xdg.configFile = {
		"wayfire.ini" = {
			source = pkgs.callPackage ./wayfire.ini.nix { };
		};
		# "wf-shell.ini" = {
		# 	source = pkgs.substituteAll {
		# 		src = ./wf-panel/wf-shell.ini;
		# 		css = ./wf-panel/wf-panel.css;
		# 		scrot = "${scrot}/bin/scrot.sh";
		# 		menu_icon = ./wf-panel/menu.png;
		# 	};
		# };
	};

	# systemd.user.targets.wayfire-session = {
	# 	Unit = {
	# 		Description = "wayfire compositor session";
	# 		BindsTo = [ "graphical-session.target" ];
	# 		Wants = [ "graphical-session-pre.target" ];
	# 		After = [ "graphical-session-pre.target" ];
	# 	};
	# };
}
