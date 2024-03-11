# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
	# # TODO: fix this.
	# tdeo = import (builtins.fetchGit {
	# 	url = "https://github.com/tadeokondrak/nix-overlay";
	# 	rev = "0d05c53204da3b576f810ef2e1312b19bf2420b7";
	# });

	utils = import <dotfiles/utils> { inherit config pkgs lib; };

	# GIMP v2.99 Nixpkgs
	gimpMesonPkgs = import (pkgs.fetchFromGitHub {
		owner  = "jtojnar";
		repo   = "nixpkgs";
		rev    = "6cb2cce589e1effb0f9983d99132c4f8cc2f4d32"; # gimp-meson
		sha256 = "0wg44l0lkrymsp68s10sx1r4fqd3yvn0lswkhn1zkd3qv6s42nmd";
	}) {};

	gnome-41 = import (pkgs.fetchFromGitHub {
		owner  = "NixOS";
		repo   = "nixpkgs";
		rev    = "3fdd780";
		sha256 = lib.fakeSha256;
	}) {};

	userEnv = {
		LC_TIME = "en_GB.UTF-8";
		NIX_AUTO_RUN = "1";
		GTK_THEME = config.home-manager.users.diamond.gtk.theme.name;
		# STEAM_RUNTIME = "0";
		# XDG_CURRENT_DESKTOP = "Wayfire";

		GOPATH = "/home/diamond/.go";
		GOBIN  = "/home/diamond/.go/bin";
		CGO_ENABLED = "0";

		# Disable VSync.
		vblank_mode = "0";

		# Enforce Wayland.
		NIXOS_OZONE_WL = "1";
		QT_QPA_PLATFORM = "wayland";
		MOZ_ENABLE_WAYLAND = "1";
		# SDL_VIDEODRIVER	= "wayland";

		# osu settings.
		WINE_RT = "89";
		WINE_SRV_RT = "99";
		STAGING_SHARED_MEMORY = "1";
		STAGING_RT_PRIORITY_BASE = "89";
		STAGING_RT_PRIORITY_SERVER = "99";
		STAGING_PA_DURATION = "250000";
		STAGING_PA_PERIOD = "8192";
   	STAGING_PA_LATENCY_USEC = "128";
	};

in {
	imports = [
		<home-manager/nixos>
		./hardware-configuration.nix
		./hardware-custom.nix
		./services
		./www
		<dotfiles/overlays>
		<dotfiles/overlays/services.nix>
		<dotfiles/secrets>
		<dotfiles/cfg/udev>
		<dotfiles/cfg/nokbd>
		<dotfiles/cfg/fonts>
		# <dotfiles/cfg/wayfire>
		<dotfiles/cfg/localhost>
		<dotfiles/cfg/keyd>
		<dotfiles/cfg/avahi>
		<dotfiles/cfg/gps>
		<dotfiles/cfg/gnome>
	];

	nixpkgs.overlays = import ./overlays;
	nixpkgs.config = {
		allowUnfree = true;
	};

	# Remote build server.
	nix = {
		# I don't understand the newer versions. Why do they break literally everything? Let's make
		# everything Flakes, but then since they're Flakes now that means they're experimental, so
		# let's break everything! Bruh.
		# package = pkgs.nix_2_3;
		# package = pkgs.nixFlakes;
		buildMachines = [
			# {
			# 	hostName = "hanaharu";
			# 	systems = [ "x86_64-linux" "i686-linux" ];
			# 	maxJobs = 2;
			# 	speedFactor = 1;
			# 	supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
			# }
			# {
			# 	hostName = "bridget";
			# 	systems  = [ "aarch64-linux" ];
			# 	maxJobs  = 1;
			# 	speedFactor = 2;
			# 	supportedFeatures = [ "nixos-test" ];
			# }
			# {
			# 	hostName = "otokonoko";
			# 	systems = [ "x86_64-linux" "i686-linux" ];
			# 	maxJobs = 2;
			# 	speedFactor = 5;
			# 	supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
			# }
		];
		distributedBuilds = true;
		extraOptions = ''
			builders-use-substitutes = true
		'';
		registry = builtins.fromJSON (builtins.readFile ./hackadoll3.registry.json);
		settings = {
			substituters = [
				# Cachix uses zstd, which Nix 2.3 does not support. Disable it.
				# "https://nix-community.cachix.org"
				"https://cache.nixos.org/"
			];
			trusted-users = [ "root" "diamond" ];
			trusted-public-keys = [
				# "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
			];
		};
	};

	# Allow aarch64 emulation.
	boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

	# Group to change SSH keys to.
	users.groups.ssh-trusted.members = [ "diamond" "root" ] ++
		(utils.formatInts 1 32 (i: "nixbld${toString i}"));

	# services.ghproxy = {
	# 	username = "diamondburned";
	# 	address  = "unix:///tmp/ghproxy.sock";
	# };

	# Enable MySQL
	# services.postgresql = {
	# 	enable = true;
	# 	enableTCPIP = false;
	# 	ensureDatabases = ["facechat"];
	# 	ensureUsers = [{
	# 		name = "diamond";
	# 		ensurePermissions = {
	# 			"DATABASE facechat" = "ALL PRIVILEGES";
	# 		};
	# 	}];
	# 	initialScript = pkgs.writeText "init.sql" ''
	# 		CREATE USER diamond;
	# 		ALTER  USER diamond WITH SUPERUSER;
	# 	'';
	# };

	# NTFS support
	boot.supportedFilesystems = [ "exfat" "ntfs" ];

	# Tired of this.
	systemd.extraConfig = ''
		DefaultTimeoutStopSec=5s
	'';

	services.journald.extraConfig = ''
		SystemMaxUse=2G
		MaxRetentionSec=3month
	'';

	# systemd-boot not used. See cfg/secureboot.
	# boot.loader.systemd-boot.enable = true;
	boot.loader.systemd-boot.configurationLimit = 25;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "hackadoll3"; # Define your hostname.
	networking.networkmanager = {
		enable = true;
		dns = "default";
	};
	# networking.nameservers = [
	# 	"1.1.1.1" "1.0.0.1"
	# ];
	networking.firewall = {
		enable = true;
		checkReversePath = false;
		allowedTCPPortRanges = [
			{ from = 1714; to = 1764; } # GSConnect
		];
		allowedUDPPortRanges = [
			{ from = 1714; to = 1764; } # GSConnect;
		];
		#                   v  Steam  v
		allowedTCPPorts = [ 27036 27037 ];
		allowedUDPPorts = [ 27031 27036 ];
		# Allow any ports for Tailscale.
		interfaces.tailscale0 = {
			allowedTCPPortRanges = [ { from = 0; to = 65535; } ];
			allowedUDPPortRanges = [ { from = 0; to = 65535; } ];
		};
	};

	# This doesn't really work.
	systemd.services.NetworkManager-wait-online.enable = false;

	networking.nat = {
		enable = true;
		internalInterfaces = [ "ve-+" ];                                                                                            
	};

	services.tailscale = {
		enable = true;
	};

	security.pki.certificateFiles = [
		<dotfiles/secrets/ssl/otokonoko.local/otokonoko.local+1.pem>
	];

	i18n = {
		inputMethod = {
			enabled	= "fcitx5";
			fcitx5.addons = with pkgs; [
				fcitx5-m17n
				fcitx5-unikey
				# fcitx5-mozc
				fcitx5-gtk
			];
		};

		defaultLocale = "en_US.UTF-8";
		supportedLocales = [
			"en_US.UTF-8/UTF-8"
			"en_GB.UTF-8/UTF-8"
			"ja_JP.UTF-8/UTF-8"
			"vi_VN/UTF-8"
		];
	};
	console.font = "Lat2-Terminus16";
	console.keyMap = "us";

	# services.keyd = {
	# 	enable = true;
	# 	configuration = {
	# 		"default.conf" = ''
	# 			[ids]
	# 			*
	# 			[main]
	# 			capslock = esc
	# 		'';
	# 	};
	# };

	environment.enableDebugInfo = true;

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		# System packages
		wget
		nix-index
		nixGL
		# nix-index-update

		# Utilities
		htop
		git
		compsize

		qgnomeplatform
		keyd
	];

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	programs.mtr.enable = true;
	programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	services.openssh = {
		enable = true;
		ports  = [ 22 ];
		settings = {
			PasswordAuthentication = false;
			X11Forwarding = true;
		};
	};

	# Enable CUPS to print documents.
	services.printing = {
		enable = true;
		drivers = with pkgs; [
			# gutenprint
			# hplip
			# cups-filters
			# cups-bjnp

			# Canon
			# cnijfilter2
			# canon-cups-ufr2
		];
	};

	# Enable the X11 windowing system.
	services.xserver.layout = "us";

	fonts.fontconfig = {
		enable = true;
		allowBitmaps = true;
		useEmbeddedBitmaps = true; # emojis
		# See fontconfig.xml.
		# subpixel = {
		# 	# http://www.spasche.net/files/lcdfiltering/
		# 	lcdfilter = "legacy";
		# 	rgba = "none";
		# };
		includeUserConf = true;
	};

	security.sudo.extraConfig = ''
		Defaults env_reset,pwfeedback
	'';

	# gnu = true;
	gtk.iconCache.enable = true;

	services.xserver.enable = true;

	# Enable touchpad support.
	services.xserver.libinput.enable = true;

	programs.xwayland = {
		enable = true;
		package = pkgs.xwayland.overrideAttrs (old: {
			# preConfigure = (old.preConfigure or "") + ''
			# 	patch -p1 < ${./patches/xwayland-fps.patch}
			# '';
		});
	};

	services.flatpak.enable = true;

	programs.seahorse.enable = true;

	services.gvfs.enable = true;
	programs.gnome-disks.enable = true;
	programs.file-roller.enable = true;

	# dbus things
	services.dbus.packages = with pkgs; [ dconf ];
	programs.dconf.enable = true;

	# Enable Polkit
	security.polkit.enable = true;

	/*
	# Enable MySQL
	services.mysql = {
		enable = true;
		package = pkgs.mariadb;
	};

	services.mysql = {
		enable = true;
		package = pkgs.mariadb;
	};
	*/

	virtualisation.docker.enable = true;
	virtualisation.spiceUSBRedirection.enable = true;

	services.sysprof.enable = true;

	virtualisation.libvirtd = {
		enable = true;
		qemu.runAsRoot = false;
	};

	# Enable the Android debug bridge.
	programs.adb.enable = true;

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.diamond = {
		isNormalUser = true;
		extraGroups = [
			"wheel" "networkmanager" "docker" "storage" "audio" "adbusers" "libvirtd" "i2c"
			"wireshark" "dialout" "input"
		];
	};

	xdg.portal = {
		enable = true;
		extraPortals = with pkgs; [
			# xdg-desktop-portal-gtk
			xdg-desktop-portal-gnome
		];
	};

	# Enable PAM user environments for GDM.
	security.pam.services.gdm-password.text = ''
        auth      substack      login
        account   include       login
        password  substack      login
        session   include       login
				session   required      pam_env.so user_readenv=1
	'';

	programs.wireshark = {
		enable  = true;
		package = pkgs.wireshark-qt;
	};

	programs.command-not-found = {
		enable = true;
		# programs.sqlite is only available if we use the nixos.org channels.
		# See hackadoll3.toml.
		dbPath = "/nix/var/nix/profiles/per-user/root/channels/unstable/programs.sqlite";
	};

	# Get a newer VTE with SIXEL for ourself.
	system.replaceRuntimeDependencies = [
		{
			original = pkgs.vte-gtk4;
			replacement = pkgs.callPackage <dotfiles/overlays/packages/vte_0.75.nix> { vte = pkgs.vte-gtk4; };
		}
		{
			original = pkgs.vte;
			replacement = pkgs.callPackage <dotfiles/overlays/packages/vte_0.75.nix> { vte = pkgs.vte; };
		}
	];

	home-manager.users.diamond = {
		imports = [
			<dotfiles/overlays>
			<dotfiles/overlays/home-manager>
			<dotfiles/secrets/diamond>
			<dotfiles/cfg/firefox>
			<dotfiles/cfg/google-chrome/home.nix>
			<dotfiles/cfg/wayfire/home.nix>
			<dotfiles/cfg/hm-blackbox-terminal.nix>
			<dotfiles/cfg/hm-gnome-terminal.nix>
			<dotfiles/cfg/hm-alacritty.nix>
			<dotfiles/cfg/git/home.nix>
			<dotfiles/cfg/gtk/home.nix>
			<dotfiles/cfg/nvim/home.nix>
			<dotfiles/cfg/gnome/home.nix>
			<dotfiles/cfg/fonts/home.nix>
			<dotfiles/cfg/zellij/home.nix>
			<dotfiles/cfg/dol-server/home.nix>

			# (import <dotfiles/utils/schedule.nix {
			# 	name        = "birthdayer-juan";
			# 	description = "Delete once Juan gets annoyed";
			# 	calendar    = "daily";
			# 	command     = "/home/diamond/.go/bin/birthdayer";
			# })
		];

		nixpkgs.config = {
			allowUnfree = true;
			overlays = import ./overlays;
		};

		programs.direnv = {
			enable = true;
			config = { load_dotenv = false; };
			nix-direnv.enable = true;
		};

		programs.bash = {
			enable = true;
			initExtra = builtins.readFile <dotfiles/cfg/bashrc>;
			historySize = 500000;
			historyFileSize = 1000000;
		};

		# programs.vscode-css = {
		# 	files = [ ./cfg/vscode.css ];
		# };
		programs.vscode = {
			# enable = true;
			# package = pkgs.nixpkgs_unstable_newer.vscode;
			# userSettings = {
			# 	"telemetry.enableTelemetry" = false;
			# 	"window.menuBarVisibility"  = "toggle";
			# 	"breadcrumbs.enabled"	   = false;
			# 	"editor.minimap.enabled"	= false;
			# };
		};

		programs.mpv = {
			enable = true;
			# package = pkgs.mpv-next;
			config = {
				osd-font = "Sans";
				osd-status-msg = "\${playback-time/full} / \${duration} (\${percent-pos}%)\\nframe: \${estimated-frame-number} / \${estimated-frame-count}";
				# profile = "gpu-hq";
				gpu-api = "auto";
				gpu-context = "auto";
				vo = "gpu";
				dither-depth = 8;
				# fbo-format = "rgba32f";
				scale = "lanczos";
				script-opts = "ytdl_hook-ytdl_path=yt-dlp";
			};
		};

		# programs.obs-studio = {
		# 	enable  = true;
		# 	plugins = with pkgs; [
		# 		# obs-backgroundremoval
		# 		# obs-studio-plugins.obs-websocket
		# 		# obs-wlrobs
		# 		# obs-v4l2sink
		# 	];
		# };

		services.easyeffects.enable = true;

		# home.file.".icons/default/index.theme".text = ''
		# 	[icon theme]
		# 	Name=Default
		# 	Comment=Default Cursor Theme
		# 	Inherits=Ardoise_shadow_87
		# '';

		# Home is for no DM, PAM is for gdm.
		# home.sessionVariables = userEnv;         # for no DM.
		pam.sessionVariables = userEnv;          # for GDM + GNOME.
		systemd.user.sessionVariables = userEnv; # for GDM + Wayfire.

		home.packages = ([
			# gimpMesonPkgs.gimp-with-plugins

		]) ++ (with pkgs.aspellDicts; [
			en
			en-science
			en-computers

		]) ++ (with pkgs.nixpkgs_21_11; [

		]) ++ (with pkgs.nixpkgs_unstable; [

		]) ++ (with pkgs.nixpkgs_unstable_real; [
			# armcord
			# vesktop
			# vencord
			# (discord.override {
			# 	withVencord = true;
			# 	withOpenASAR = false;
			# })
			# blackbox-terminal
			# evolutionWithPlugins

			# xelfviewer
			# (import <nixpkgs_shotcut> {}).shotcut
			# gnvim

			# Browsers
			# google-chrome

		]) ++ (with pkgs; [
			# Personal stuff
			gnome.pomodoro
			gnome-usage
			gnome.polari
			gnome.pomodoro
			gnomeExtensions.gsconnect
			gnomeExtensions.dash-to-panel
			gnomeExtensions.tiling-assistant
			gnomeExtensions.brightness-control-using-ddcutil
			gnomeExtensions.search-light
			gnomeExtensions.rounded-window-corners
			gnomeExtensions.expandable-notifications
			gnomeExtensions.notification-banner-reloaded
			keepassxc
			# gimp-with-plugins
			gimp
			git-crypt
			gnupg
			gnuplot
			drawing
			sticky
			fragments
			alarm-clock-applet
			# mixxx
			yt-dlp
			(nixpkgs_unstable_newer.callPackage <dotfiles/overlays/packages/mixxx/beta.nix> {})

			# System
			xorg.xhost # dependency for wsudo
			ddcutil
			powertop
			blueberry
			libcanberra-gtk3
			fcitx5-configtool
			fcitx5-gtk
			libsForQt5.fcitx5-qt
			wl-clipboard
			playerctl
			waypipe
			bottles
			# gatttool

			rmtrash
			# Force rm to use rmtrash.
			(pkgs.writeShellScriptBin "rm" ''
				if [[ "$USER" == diamond ]]; then
					exec ${rmtrash}/bin/rmtrash --forbid-root=ask-forbid "$@"
				else
					exec ${pkgs.coreutils}/bin/rm "$@"
				fi
			'')

			# Development tools
			sommelier
			dos2unix
			rnix-lsp
			foot
			silver-searcher
			jq
			gh
			go
			gopls
			gotools
			licensor
			mdr
			# config.boot.kernelPackages.perf
			# perf_data_converter
			tree
			fzf
			graphviz
			gnuplot
			vimHugeX
			clang-tools
			xclip
			virt-manager
			xorg.xauth
			grun
			# neovide
			# neovim-gtk

			protonup
			gamescope
			(steam.override ({ extraLibraries ? pkgs': [], ... }: {
				# Workaround for TF2.
				# See https://github.com/ValveSoftware/Source-1-Games/issues/5043#issuecomment-1822019817.
        extraLibraries = pkgs': (extraLibraries pkgs') ++ ( [
          pkgs'.gperftools
        ]);
      }))

			# Multimedia
			# aqours
			# (succumb-to-libadwaita spot)
			spot
			libva-utils
			# catnip-gtk
			ffmpeg
			v4l-utils
			pavucontrol
			pulseaudio
			pamixer
			easyeffects
			lollypop
			komikku
			# ytmdesktop # not until v2 is ready
			youtube-music
			monophony
			spotify

			# # Chat/Social
			# # zoom-us
			# discord
			dissent
			vesktop
			# (pkgs.callPackage <unstable/pkgs/by-name/ve/vesktop/package.nix> {})
			# gotktrix
			# # fractal

			# Office
			libreoffice
			nixpkgs_unstable_older.qalculate-gtk
			onlyoffice-bin
			evince
			aspell
			nixpkgs_unstable_newer.marker
			graphviz
			# foliate

			# Applications
			gcolor3
			# google-chrome

			# Themes
			papirus-icon-theme
			material-design-icons
			catppuccin-cursors.mochaPink
			catppuccin-cursors.macchiatoPink
			catppuccin-cursors.mochaFlamingo
			catppuccin-cursors.macchiatoFlamingo
			catppuccin-gtk

			# Games
			# polymc
			prismlauncher
			# osu-wine
			# osu-wine-realistik

			# GNOME things
			kooha
			snapshot
			glib-networking
			celluloid
			gnome.gnome-power-manager
			gnome.eog
			gnome.vinagre
			gnome.file-roller
			gnome.nautilus
			nautilus-open-any-terminal
			gnome.gnome-disk-utility
			gnome.gnome-tweaks
			gnome.gnome-boxes

			# Everything in ./bn
			(runCommand "diamond-bin" {} ''
				mkdir -p $out/bin
				cp -r ${<dotfiles/bin>}/* $out/bin
			'')
		]);

		systemd.user.services = {
			# terminal = utils.waylandService "gnome-terminal";
			# nautilus = utils.waylandService "nautilus --gapplication-service";
		};

		fonts.fontconfig.enable = lib.mkForce true;

		xdg = {
			enable = true;
			mime.enable = true;
			# mimeApps = {
			# 	enable = true;
			# 	defaultApplications = {
			# 		"default-web-browser" = [ "firefox.desktop" ];
			# 	};
			# };
			configFile = {
				"zls.json".text = builtins.toJSON {
					enable_snippets = false;
					zig_exe_path = "${pkgs.zig}/bin/zig";
					zig_lib_path = "${pkgs.zig}/lib/zig";
					warn_style = true;
					enable_semantic_tokens = true;
				};
				"fontconfig/fonts.conf".source = <dotfiles/cfg/fontconfig.xml>;
				"autostart/autostart.desktop".text = utils.mkDesktopFile {
					name = "autostart-init";
					exec = <dotfiles/bin/autostart>;
					type = "Application";
					comment = "An autostart script in ~/Scripts/nix/bin/autostart";
					extraEntries = ''
						NotShowIn=desktop-name
						X-GNOME-Autostart-enabled=true
					'';
				};
				# Allow non-free for user
				"nixpkgs/config.nix".text = "{ allowUnfree = true; }";
				"nix/nix.conf".text = ''
					experimental-features = nix-command flakes
				'';
			};
		};

		home.stateVersion = "20.09";
	};

	# system.stateVersion = "20.03"; # DO NOT TOUCH
	system.stateVersion = "20.09"; # I TOUCHED.
}
