# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let home-manager = builtins.fetchGit {
		url = "https://github.com/nix-community/home-manager.git";
		ref = "master";
	};

	lsoc-overlay = builtins.fetchGit {
		url = "https://github.com/diamondburned/lsoc-overlay.git";
		rev = "09d41b0a6f574390d6edc0271be459bd1390ea8d";
	};

	# TODO: fix this.
	tdeo = import (builtins.fetchGit {
		url = "https://github.com/tadeokondrak/nix-overlay";
		rev = "0d05c53204da3b576f810ef2e1312b19bf2420b7";
	});

	diamond = ../nix-overlays;

	utils = import ./utils.nix { inherit config pkgs lib; };

	# GIMP v2.99 Nixpkgs
	gimpMesonPkgs = import (pkgs.fetchFromGitHub {
		owner  = "jtojnar";
		repo   = "nixpkgs";
		rev	= "dc2786744e50290e290d591a75f6cc512cf31a1b";
		sha256 = "0c5im5dzrs5a25x6g2njd4k48qirv48iavwvl5ylyvwkmfhqk9f9";
	}) {};

	userEnv = {
		NIX_AUTO_RUN = "1";
		STEAM_RUNTIME = "0";
		# XDG_CURRENT_DESKTOP = "Wayfire";

		GOPATH = "/home/diamond/.go";
		GOBIN  = "/home/diamond/.go/bin";
		CGO_ENABLED = "0";

		# Disable VSync.
		vblank_mode = "0";

		# Enforce Wayland.
		MOZ_ENABLE_WAYLAND = "1";
		SDL_VIDEODRIVER	= "wayland";
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

in

{
	imports = [
		"${diamond}"
		"${home-manager}/nixos"
		./hardware-configuration.nix
		./hardware-custom.nix
		./unstable.nix
		./cfg/wayfire
		./cfg/localhost
	];

	# Overlays
	nixpkgs.overlays =
	let vte = pkgs: pkgs.vte.overrideAttrs(old: {
			version = "0.63.91"; # rev without SIXEL reversion commit.
			src = builtins.fetchGit {
				url = "https://gitlab.gnome.org/GNOME/vte.git";
				rev = "35b0a8dc9776300bd33c8106e500436b6c11fccc";
			};
			postPatch = (old.postPatch or "") + ''
				patchShebangs src/*.py
			'';
			nativeBuildInputs = old.nativeBuildInputs ++ (with pkgs; [
				python3
				python3Full
			]);
			patches = (old.patches or []) ++ [
				./patches/vte-fast.patch
			];
		});
	in [
		(tdeo)
		(self: super: {
			# This might be causing painful rebuilds.
			# vte = vte super;

			# aspell	  = aspellPkgs.aspell;
			# gspell	  = aspellPkgs.gspell;
			# aspellDicts = aspellPkgs.aspellDicts;

			# GIMP v2.99
			# gimp = gimpMesonPkgs.gimp;

			# # orca hate
			# orca = super.orca.overrideAttrs(old: {
			# 	postInstall = (old.postInstall or "") + ''
			# 		:> $out/etc/xdg/autostart/orca-autostart.desktop
			# 	'';
			# });

			# mpv-unwrapped = super.mpv-unwrapped.overrideAttrs (old: {
			# 	version = "0.33.1-0";
			# 	patches = [];
			# 	src = super.fetchFromGitHub {
			# 		owner  = "mpv-player";
			# 		repo   = "mpv";
			# 		rev	= "93066ff12f06d47e7a1a79e69a4cda95631a1553";
			# 		sha256 = "0cw9qh41lynfx25pxpd13r8kyqj1zh86n0sxyqz3f39fpljr9w4r";
			# 	};
			# });
			morph = super.morph.overrideAttrs(_: {
				version = "1.4.0";
				src = builtins.fetchGit {
					url = "https://github.com/diamondburned/morph.git";
					ref = "merges";
					rev = "a3ef469edf1613b8ab51de87e043c3c57d12a4a9";
				};
			});
			# Omitted because it's too much to compile.
			# osu-wine = super.osu-wine.override {
			# 	wine = aspellPkgs.wineStaging.overrideDerivation(old: {
			# 		NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -DNDEBUG -Ofast -mfpmath=sse -mtune=intel -march=skylake";
			# 		postPatch = (old.postPatch or "") + ''
			# 			patch -Np1 < ${./patches/wine-4.2-alsa-lower-latency.patch}
			# 			patch -Np1 < ${./patches/wine-4.2-pulseaudio-lower-latency.patch}
			# 		'';
			# 	});
			# };
			# xwayland = super.xwayland.overrideAttrs (old: {
			# 	preConfigure = (old.preConfigure or "") + ''
			# 		patch -p1 < ${./patches/xwayland-fps.patch}
			# 	'';
			# });
			steam = let pkgs = pkgs: with pkgs; [
					SDL2
					pkgsi686Linux.SDL2
				];
				in super.steam.override {
					extraPkgs = pkgs;
					extraLibraries = pkgs;
					extraProfile = ''
						export STEAM_RUNTIME=0
						export STEAM_RUNTIME_PREFER_HOST_LIBRARIES=1
						export LD_LIBRARY_PATH="${super.SDL2}/lib:$LD_LIBRARY_PATH"
					'';
				};
		})
	];

	nixpkgs.config = {
		allowUnfree = true;
	};

	# Remote build server.
	nix = {
		buildMachines = [{
			hostName = "hanaharu";
			systems = [ "x86_64-linux" "i686-linux" ];
			maxJobs = 2; # max 8
			speedFactor = 10;
			supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
		}];
		trustedUsers = [ "root" "diamond" ];
		distributedBuilds = true;
		extraOptions = "builders-use-substitutes = true";
	};

	programs.ssh.extraConfig = utils.sshFallback {
		tryAddr  = "192.168.1.169";
		elseAddr = "home.arikawa-hi.me";
		host = "hanaharu";
		user = "diamond";
		port = "1337";
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
		#					  v  Steam  v
		allowedTCPPorts = [ 22 27036 27037 ];
		allowedUDPPorts = [ 22 27031 27036 ];
	};

	i18n = {
		inputMethod = {
			enabled	= "fcitx";
			# TODO re-enable fcitx5
			fcitx.engines = with pkgs.fcitx-engines; [ mozc unikey ];
		};

		defaultLocale = "en_US.UTF-8";
		supportedLocales = [
			"en_US.UTF-8/UTF-8"
			"ja_JP.UTF-8/UTF-8"
			"vi_VN/UTF-8"
		];
	};
	console.font = "Lat2-Terminus16";
	console.keyMap = "us";

	# Set your time zone.
	time.timeZone = "America/Los_Angeles";

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		# System packages
		wget
		nix-index

		# Utilities
		# htop
		git

		qgnomeplatform
		adwaita-qt
	];

	# Install global fonts
	fonts.fonts = with pkgs; [
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji
		source-code-pro
		source-sans-pro
		source-serif-pro
		fira-code
		nerdfonts
		material-design-icons
		inconsolata
		comic-neue
		blobmoji
		tewi-font
	];
	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	programs.mtr.enable = true;
	programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	services.openssh.enable = true;

	# Enable CUPS to print documents.
	services.printing = {
		enable = true;
		drivers = with pkgs; [
			# gutenprint
			# hplip
			# cups-filters
			# cups-bjnp

			# Canon
			cnijfilter2
			canon-cups-ufr2
		];
	};

	# Enable sound.
	sound.enable = true;
	hardware.pulseaudio.enable = lib.mkForce false;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		jack.enable = true;
		pulse.enable = true;

		# https://nixos.wiki/wiki/PipeWire
		media-session.config.bluez-monitor.rules = [
			{
				# Match all.
				matches = [ { "device.name" = "~bluez_card.*"; } ];
				actions = {
					"update-props" = {
						"bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
						"bluez5.msbc-support" = true;
						"bluez5.sbc-xq-support" = true;
					};
				};
			}
		];
	};

	# Enable the X11 windowing system.
	services.xserver.layout = "us";

	fonts.fontconfig = {
		enable = true;
		allowBitmaps = true;
		useEmbeddedBitmaps = true; # emojis
		subpixel = {
			lcdfilter = "default";
			rgba = "none";
		};
		includeUserConf = true;
		hinting.enable = false;
	};

	security.sudo.extraConfig = ''
		Defaults env_reset,pwfeedback
	'';

	services.xserver.enable = true;

	# Enable touchpad support.
	services.xserver.libinput.enable = true;

	# Disable the GNOME desktop environment
	services.xserver.desktopManager.gnome.enable = true;

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

	services.flatpak.enable = false;

	environment.gnome.excludePackages = with pkgs.gnome3; [
		orca
		totem
		gnome-maps
		gnome-contacts
		gnome-initial-setup
	];

	programs.seahorse.enable = true;

	services.gvfs.enable = true;
	programs.gnome-disks.enable = true;
	programs.file-roller.enable = true;

	# dbus things
	services.dbus.packages = with pkgs; [ gnome3.dconf ];

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

	virtualisation.docker.enable = true;
	*/

	# virtualisation.libvirtd = {
	# 	enable = true;
	# 	qemuPackage = nixpkgs_19_09.qemu_kvm;
	# 	qemuRunAsRoot = false;
	# };

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

	xdg.portal = {
		enable = true;
		extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
		gtkUsePortal = true;
	};

	home-manager.users.diamond = {
		imports = [
			"${lsoc-overlay}"
			"${diamond}/home-manager"

			./cfg/tilix
			./cfg/firefox
			./cfg/hm-gnome-terminal.nix
		];

		nixpkgs.config = {
			allowUnfree = true;
		};

		programs.direnv = {
			enable = true;
			nix-direnv.enable = true;
		};

		programs.git = {
			enable = true;
			userName  = "diamondburned";
			userEmail = "datutbrus@gmail.com";
			extraConfig = {
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

		programs.vscode-css = {
			files = [ ./cfg/vscode.css ];
		};
		programs.vscode = {
			enable = true;
			# userSettings = {
			# 	"telemetry.enableTelemetry" = false;
			# 	"window.menuBarVisibility"  = "toggle";
			# 	"breadcrumbs.enabled"	   = false;
			# 	"editor.minimap.enabled"	= false;
			# };
		};

		programs.mpv = {
			enable = true;
			config = {
				osd-font = "Sans";
				# profile = "gpu-hq";
				gpu-api = "auto";
				gpu-context = "auto";
				vo = "gpu";
				dither-depth = 8;
				fbo-format = "rgba32f";
				scale = "lanczos";
			};
		};

		programs.obs-studio = {
			enable  = true;
			plugins = with pkgs; [
				# obs-wlrobs
				# obs-v4l2sink
			];
		};

		gtk = {
			enable = true;
			font.name = "Sans";
			theme.name = "Materia-dark-compact";
			iconTheme.name = "Papirus-Dark";

			gtk3 = {
				extraConfig = {
					gtk-application-prefer-dark-theme = 1;
				};
				extraCss = builtins.readFile ./cfg/gtk.css;
			};
		};

		# Home is for no DM, PAM is for gdm.
		home.sessionVariables = userEnv;
		pam.sessionVariables = userEnv;

		home.packages = ([

		]) ++ (with pkgs.aspellDicts; [
			en
			en-science
			en-computers

		]) ++ (with pkgs; [
			# Personal stuff
			gnome3.gnome-usage
			gnome3.polari
			gnome3.pomodoro
			keepassx-community
			gnupg
			gimp-with-plugins

			# System
			(writeScriptBin "wsudo" (builtins.readFile ./bin/wsudo))
			xorg.xhost # dependency for wsudo

			# Development tools
			neovim
			foot
			jq
			gtk4.dev
			fzf
			graphviz
			gnuplot
			vimHugeX
			clang-tools
			xclip
			virt-manager
			xorg.xauth

			# Multimedia
			ffmpeg
			v4l_utils
			pavucontrol
			pulseaudio
			easyeffects

			# Browsers
			google-chrome

			# Chat/Social
			zoom-us
			tdesktop
			# fractal # lol

			# Office
			libreoffice
			evince

			# Applications
			gcolor3

			# Themes
			materia-theme
			material-design-icons

			# Games
			# osu-wine

			# GNOME things
			gnome-mpv
			gnome3.eog
			gnome3.vinagre
			gnome3.glib-networking
			gnome3.file-roller
			gnome3.nautilus
			gnome3.gnome-disk-utility
			gnome3.gtk.dev
			gnome3.gnome-tweaks
		]);

		programs.alacritty = {
			enable = true;
			settings = {
				font = let font = { family = "monospace"; }; in {
					normal = font;
					bold   = font;
					italic = font;
					size   = 11;
				};
			};
		};

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
			};
		};
	};

	system.stateVersion = "20.03"; # DO NOT TOUCH
}
