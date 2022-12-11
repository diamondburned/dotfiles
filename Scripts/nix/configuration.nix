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
		./unstable.nix
		./overlays
		./overlays/services.nix
		./secrets
		./configroot.nix
		./cfg/udev
		# ./cfg/wayfire
		./cfg/pipewire
		./cfg/localhost
		./cfg/keyd
	];

	nixpkgs.config = {
		allowUnfree = true;
	};

	# Remote build server.
	nix = {
		# I don't understand the newer versions. Why do they break literally everything? Let's make
		# everything Flakes, but then since they're Flakes now that means they're experimental, so
		# let's break everything! Bruh.
		package = pkgs.nix_2_3;
		# package = pkgs.nixFlakes;
		buildMachines = [
			{
				hostName = "hanaharu";
				systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
				maxJobs = 8;
				speedFactor = 10;
				supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
			}
			# {
			# 	hostName = "otokonoko";
			# 	systems = [ "x86_64-linux" "i686-linux" ];
			# 	maxJobs = 2;
			# 	speedFactor = 5;
			# 	supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
			# }
		];
		trustedUsers = [ "root" "diamond" ];
		distributedBuilds = true;
		extraOptions = ''
			builders-use-substitutes = true
		'';
		settings = {
			substituters = [
				"https://nix-community.cachix.org"
				"https://cache.nixos.org/"
			];
			trusted-public-keys = [
				"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
			];
		};
	};

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

	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "hackadoll3"; # Define your hostname.
	networking.networkmanager = {
		enable = true;
		dns = "default";
	};
	networking.nameservers = [
		"1.1.1.1" "1.0.0.1"
	];
	networking.firewall = {
		enable = false;
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

	services.avahi = {
		enable = true;
		nssmdns = true;
		publish = {
			enable = true;
			domain = true;
			addresses = true;
			workstation = true;
		};
		interfaces = [
			# USB-C Ethernet dock.
			"enp0s20f0u2u1"
		];
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

	# Set your time zone.
	time.timeZone = "America/Los_Angeles";

	environment.enableDebugInfo = true;

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		# System packages
		wget
		nix-index
		# nix-index-update

		# Utilities
		# htop
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
		# blobmoji
		tewi-font
	]) ++ (with pkgs.nixpkgs_unstable_real; [
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji
	]);
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

		# Enable the Keyring for password managing
		gnome-keyring.enable = true;

		# Online stuff
		gnome-user-share.enable = true;
		gnome-online-accounts.enable = true;
		gnome-online-miners.enable = true;
		chrome-gnome-shell.enable = true;

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

	environment.gnome.excludePackages = with pkgs; [
		# gnome-maps
		# gnome-contacts
		# gnome-initial-setup
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
		qemuRunAsRoot = false;
	};

	# Enable the Android debug bridge.
	programs.adb.enable = true;

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.diamond = {
		isNormalUser = true;
		extraGroups = [ "wheel" "networkmanager" "docker" "storage" "audio" "adbusers" "libvirtd" ];
	};

	qt5 = {
		enable = true;
		style = "adwaita-dark";
		platformTheme = "gnome";
	};

	# xdg.portal = {
	# 	enable = true;
	# 	# extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
	# 	gtkUsePortal = true;
	# };

	# Enable PAM user environments for GDM.
	security.pam.services.gdm-password.text = ''
        auth      substack      login
        account   include       login
        password  substack      login
        session   include       login
		session   required      pam_env.so user_readenv=1
	'';

	# programs.wireshark = {
	# 	enable  = true;
	# 	package = pkgs.wireshark-qt;
	# };

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
				pull = {
					rebase = true;
				};
			};
		};

		programs.bash = {
			enable = true;
			initExtra = builtins.readFile ./cfg/bashrc;
		};

		# programs.vscode-css = {
		# 	files = [ ./cfg/vscode.css ];
		# };
		programs.vscode = {
			enable = true;
			package = pkgs.vscode;
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
			};
		};

		programs.obs-studio = {
			enable  = true;
			plugins = with pkgs; [
				# obs-backgroundremoval
				# obs-studio-plugins.obs-websocket
				# obs-wlrobs
				# obs-v4l2sink
			];
		};

		gtk = {
			enable = true;
			font.name = "Sans";

			theme = {
				name = userEnv.GTK_THEME;
				package = pkgs.orchis-theme.override {
					tweaks = [ "black" "compact" ];
				};
			};
			iconTheme = {
				name = "Papirus-Dark";
				package = pkgs.papirus-icon-theme;
			};

			gtk3 = {
				extraConfig = {
					gtk-application-prefer-dark-theme = 1;
				};
				extraCss = builtins.readFile ./cfg/gtk.css;
			};
		};

		# xsession.pointerCursor = {
			# package = 
		# };
		home.file.".icons/default/index.theme".text = ''
			[icon theme]
			Name=Default
			Comment=Default Cursor Theme
			Inherits=Ardoise_shadow_87
		'';

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

		]) ++ (with pkgs.nixpkgs_unstable; [
			# (gamescope)

		]) ++ (with pkgs.nixpkgs_unstable_real; [
			spotify
			blackbox-terminal
			# gamescope
			(steam.override {
				extraPkgs = pkgs: with pkgs; [
					# gamescope
				];
			})

		]) ++ (with pkgs; [
			# Personal stuff
			gnome.pomodoro
			gnome-usage
			gnome.polari
			gnome.pomodoro
			gnomeExtensions.gsconnect
			gnomeExtensions.easyScreenCast
			keepassxc
			gimp-with-plugins
			git-crypt
			gnupg
			gnuplot
			intiface-cli

			# System
			(writeScriptBin "wsudo" (builtins.readFile ./bin/wsudo))
			xorg.xhost # dependency for wsudo
			powertop
			blueberry
			libcanberra-gtk3
			fcitx5-configtool
			# gatttool

			# Development tools
			dos2unix
			foot
			jq
			go_1_18
			mdr
			# xelfviewer
			config.boot.kernelPackages.perf
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

			(with nixpkgs_copilot; wrapNeovimUnstable neovim-unwrapped
				# Use unstable Neovim with a slightly outdated Nixpkgs because
				# Copilot is fucking trash.
				(neovimUtils.makeNeovimConfig {
					vimAlias = true;
					withNodeJs = true;
					customRC = builtins.readFile ./cfg/nvimrc;
				})
			)

			# Multimedia
			# aqours
			# (succumb-to-libadwaita spot)
			spot
			# catnip-gtk
			ffmpeg
			v4l-utils
			pavucontrol
			pulseaudio
			pamixer
			easyeffects

			# Browsers
			google-chrome

			# # Chat/Social
			# # zoom-us
			tdesktop
			discord
			gtkcord4
			gotktrix
			# # fractal

			# Office
			qalculate-gtk
			libreoffice
			onlyoffice-bin
			evince
			aspell
			marker

			# Applications
			gcolor3

			# Themes
			papirus-icon-theme
			materia-theme
			material-design-icons

			# Games
			# polymc
			# prismlauncher
			osu-wine
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
			gnome.gnome-disk-utility
			gnome.gnome-tweaks
			gnome.gnome-boxes
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
				"nvim/init.vim".source = ./cfg/nvimrc;
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
				# "nix/config.nix".text = ''
				# 	experimental-featuers = nix-command
				# '';
			};
		};

		home.stateVersion = "20.09";
	};

	# system.stateVersion = "20.03"; # DO NOT TOUCH
	system.stateVersion = "20.09"; # I TOUCHED.
}
