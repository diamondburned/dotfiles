# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let lsoc-overlay = pkgs.fetchFromGitHub {
		owner = "diamondburned";
		repo  = "lsoc-overlay";
		rev   = "09d41b0a6f574390d6edc0271be459bd1390ea8d";
		hash  = "sha256:0a27vwknk442k6wz29xk0gs4m8nhjwalq642xrcac45v97z5glc3";
	};

	# # TODO: fix this.
	# tdeo = import (builtins.fetchGit {
	# 	url = "https://github.com/tadeokondrak/nix-overlay";
	# 	rev = "0d05c53204da3b576f810ef2e1312b19bf2420b7";
	# });

	utils = import ./utils { inherit config pkgs lib; };

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
		# STEAM_RUNTIME = "0";
		GTK_THEME = "Orchis-Pink-Dark-Compact";
		# XDG_CURRENT_DESKTOP = "Wayfire";

		GOPATH = "/home/diamond/.go";
		GOBIN  = "/home/diamond/.go/bin";
		CGO_ENABLED = "0";

		# Disable VSync.
		vblank_mode = "0";

		# Enforce Wayland.
		NIXOS_OZONE_WL = "1";
		MOZ_ENABLE_WAYLAND = "1";
		# SDL_VIDEODRIVER	= "wayland";
		QT_QPA_PLATFORM	= "wayland";

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
		./overlays
		./overlays/services.nix
		./secrets
		./configroot.nix
		./cfg/udev
		./cfg/nokbd
		# ./cfg/wayfire
		./cfg/localhost
		./cfg/keyd
		./cfg/avahi
	];

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
		enable = false;
		checkReversePath = false;
		allowedTCPPortRanges = [
			{ from = 1714; to = 1764; } # GSConnect
		];
		allowedUDPPortRanges = [
			{ from = 1714; to = 1764; } # GSConnect;
		];
		#                        v  Steam  v
		allowedTCPPorts = [ 1337 27036 27037 ];
		allowedUDPPorts = [ 1337 27031 27036 ];
	};
	networking.nat = {
		enable = true;
		internalInterfaces = [ "ve-+" ];                                                                                            
	};

	security.pki.certificateFiles = [
		./secrets/ssl/otokonoko.local/otokonoko.local+1.pem
	];

	i18n = {
		inputMethod = {
			enabled	= "fcitx5";
			fcitx5.addons = with pkgs; [
				fcitx5-m17n
				fcitx5-mozc
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
		# nix-index-update

		# Utilities
		htop
		git
		compsize

		qgnomeplatform
		adwaita-qt
		keyd
	];

	# Install global fonts
	fonts.fonts = (with pkgs; [
		bakoma_ttf # math
		# opensans-ttf
		roboto
		roboto-slab # serif
		source-code-pro
		source-sans-pro
		source-serif-pro
		fira-code
		# nerdfonts
		inconsolata-nerdfont
		material-design-icons
		inconsolata
		comic-neue
		tewi-font
		unifont
	]) ++ (with pkgs.nixpkgs_unstable_real; [
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji
	]);
	fonts.fontconfig.defaultFonts = {
		serif = [
			"serif"
			"Noto Serif"
		];
		sansSerif = [
			"sans-serif"
			"Open Sans"
			"Source Sans 3"
			"Source Sans Pro"
			"Noto Sans"
		];
		monospace = [
			"Inconsolata"
			"Symbols Nerd Font"
			"Source Code Pro"
			"Noto	Sans Mono"
			"emoji"
			"symbol"
			"Unifont"
			"Unifont Upper"
		];
		emoji = [
			"Noto Color Emoji"
		];
	};
	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	programs.mtr.enable = true;
	programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	services.openssh = {
		enable = true;
		ports  = [ 1337 ];
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

	# Enable the GNOME desktop environment
	services.xserver.desktopManager.gnome.enable = true;

	# Enable GDM.
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.displayManager.gdm.autoSuspend = true;

	# More GNOME things
	services.gnome = {
		core-shell.enable = true;
		core-os-services.enable = true;
		gnome-settings-daemon.enable = true;
		core-utilities.enable = true;

		# Enable the Keyring for password managing
		gnome-keyring.enable = true;

		# Online stuff
		gnome-user-share.enable = true;
		gnome-online-accounts.enable = true;
		gnome-online-miners.enable = true;
		gnome-browser-connector.enable = true;

		# Disable garbage
		tracker.enable = false;
		tracker-miners.enable = false;
		gnome-initial-setup.enable = false;
	};

	programs.kdeconnect = {
		enable  = true;
		package = pkgs.gnomeExtensions.gsconnect;
	};

	services.flatpak.enable = true;

	environment.gnome.excludePackages = with pkgs; with pkgs.gnome; [
		gnome-contacts
		gnome-initial-setup
		gnome-calendar
		epiphany
		yelp
		geary
		totem
		cheese
		tracker-miners
		sushi
		gnome-photos
		gnome-music
	];

	programs.seahorse.enable = true;

	services.gvfs.enable = true;
	programs.gnome-disks.enable = true;
	programs.file-roller.enable = true;

	# dbus things
	services.dbus.packages = with pkgs; [ dconf ];

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
			"wireshark"
		];
	};

	qt = {
		enable = true;
		style = "adwaita-dark";
		platformTheme = "gnome";
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

	home-manager.users.diamond = {
		imports = [
			"${lsoc-overlay}"

			./overlays
			./overlays/home-manager
			./configroot.nix
			./secrets/diamond
			# ./cfg/wyze
			# ./cfg/tilix
			./cfg/firefox
			# ./cfg/pantalaimon
			# ./cfg/wayfire/home.nix
			./cfg/hm-blackbox-terminal.nix
			./cfg/hm-gnome-terminal.nix
			./cfg/hm-alacritty.nix

			# Automatically push dotfiles.
			(import ./utils/schedule.nix {
				name        = "dotfiles-pusher";
				description = "Automatically push dotfiles";
				calendar    = "hourly";
				command     = ''
					cd ~/ && git add -A && git commit -m Update && git push origin
					exit 0
				'';
			})

			(import ./utils/schedule.nix {
				name        = "birthdayer-juan";
				description = "Delete once Juan gets annoyed";
				calendar    = "daily";
				command     = "/home/diamond/.go/bin/birthdayer";
			})
		];

		nixpkgs.config = {
			allowUnfree = true;
		};

		programs.direnv = {
			enable = true;
			config = { load_dotenv = false; };
			nix-direnv.enable = true;
		};

		programs.git = {
			enable = true;
			userName  = "diamondburned";
			userEmail = "diamond@arikawa-hi.me";
			signing = {
				key = "D78C4471CE776659";
				signByDefault = true;
			};
			lfs.enable = true;
			extraConfig = {
				http = {
					cookieFile = "/home/diamond/.gitcookies";
				};
				core = {
					excludesfile = "${pkgs.writeText "gitignore" (
						builtins.concatStringsSep "\n" [
							".envrc"
							".direnv"
						]
					)}";
				};
				url = {
					"ssh://git@github.com/" = { insteadOf = "https://github.com/"; };
					"ssh://git@gitlab.com/" = { insteadOf = "https://gitlab.com/"; };
				};
				pull.rebase = true;
				push.autoSetupRemote = true;
			};
		};

		programs.bash = {
			enable = true;
			initExtra = builtins.readFile ./cfg/bashrc;
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

		gtk = {
			enable = true;
			font.name = "Sans";
			font.size = 11;

			theme = {
				name = userEnv.GTK_THEME;
				package =
					# let orchis-theme = pkgs.orchis-theme.overrideAttrs (old: rec {
					# 	version = "2023-01-25";
					# 	src = pkgs.fetchFromGitHub {
					# 	    repo = "Orchis-theme";
					# 	    owner = "vinceliuice";
					# 	    rev = version;
					# 	    sha256 = "sha256:0rlvqzlfabvayp9p2ihw4jk445ahhrgv6zc5n47sr5w6hbb082ny";
					# 	};
					# });
					let orchis-theme = pkgs.nixpkgs_unstable_real.orchis-theme.overrideAttrs (old: {
						patches = (old.patches or []) ++ [
							./overlays/patches/Orchis-theme-middark.patch
						];
					});
					in orchis-theme.override {
						tweaks = [ "compact" ];
						border-radius = 6;
					};
			};

			iconTheme = {
				name = "Papirus-Dark";
				package = pkgs.papirus-icon-theme;
			};

			cursorTheme = {
				name = "Catppuccin-Mocha-Pink-Cursors";
				size = 32;
			};

			gtk3 = {
				extraConfig = {
					gtk-application-prefer-dark-theme = 1;
				};
				# extraCss = builtins.readFile ./cfg/gtk.css;
			};
		};

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
			# (gamescope)

		]) ++ (with pkgs.nixpkgs_unstable_real; [
			spotify
			blackbox-terminal
			evolutionWithPlugins

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

			# System
			xorg.xhost # dependency for wsudo
			powertop
			blueberry
			libcanberra-gtk3
			fcitx5-configtool
			fcitx5-gtk
			wl-clipboard
			playerctl
			# gatttool

			# Force rm to use rmtrash.
			rmtrash
			(pkgs.writeShellScriptBin "rm" ''
				exec ${rmtrash}/bin/rmtrash --forbid-root=ask-forbid "$@"
			'')

			# Development tools
			sommelier
			dos2unix
			rnix-lsp
			foot
			silver-searcher
			jq
			go
			gopls
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
			octave-soft
			grun
			# neovim-gtk

			protonup
			(steam.override {
				extraPkgs = pkgs: with pkgs; [
					(mangohud)
					(import <nixpkgs_pr_230931> {}).gamescope
			 	];
			})
			(import <nixpkgs_pr_230931> {}).gamescope

			(wrapNeovimUnstable neovim-unwrapped
				# Use unstable Neovim with a slightly outdated Nixpkgs because
				# Copilot is fucking trash.
				(neovimUtils.makeNeovimConfig {
					vimAlias = true;
					withNodeJs = true;
					customRC = builtins.readFile ./cfg/nvim/init.vim;
					plugins = with pkgs.vimPlugins; [
						{ plugin = markdown-preview-nvim; }
					];
				})
			)

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

			# # Chat/Social
			# # zoom-us
			discord
			gtkcord4
			tdesktop
			# gotktrix
			# # fractal

			# Office
			qalculate-gtk
			libreoffice
			onlyoffice-bin
			evince
			aspell
			marker
			graphviz
			# foliate

			# Applications
			gcolor3
			google-chrome

			# Themes
			papirus-icon-theme
			materia-theme
			material-design-icons
			catppuccin-cursors.mochaPink
			catppuccin-cursors.macchiatoPink
			catppuccin-cursors.mochaFlamingo
			catppuccin-cursors.macchiatoFlamingo
			catppuccin-gtk

			# Games
			# polymc
			# prismlauncher
			# osu-wine
			# osu-wine-realistik

			# GNOME things
			xfce.thunar
			kooha
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

			# Everything in ./bin
			(runCommand "diamond-bin" {} ''
				mkdir -p $out/bin
				cp -r ${./bin}/* $out/bin
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
				"fontconfig/fonts.conf".source = ./cfg/fontconfig.xml;
			 	"nvim/init.vim".source = ./cfg/nvim/init.vim;
				"autostart/autostart.desktop".text = utils.mkDesktopFile {
					name = "autostart-init";
					exec = ./bin/autostart;
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
				"gtk-4.0/gtk.css".source = ./cfg/gtk.css;
				"gtk-3.0/gtk.css".source = ./cfg/gtk.css;
			};
		};

		home.stateVersion = "20.09";
	};

	# system.stateVersion = "20.03"; # DO NOT TOUCH
	system.stateVersion = "20.09"; # I TOUCHED.
}
