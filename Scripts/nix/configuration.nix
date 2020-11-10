# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let home-manager = builtins.fetchGit {
		url = "https://github.com/rycee/home-manager.git";
		rev = "249650a07ee2d949fa599f3177a8c234adbd1bee";
		ref = "master";
	};

	lsoc-overlay = builtins.fetchGit {
		url = "https://github.com/diamondburned/lsoc-overlay.git";
		rev = "09d41b0a6f574390d6edc0271be459bd1390ea8d";
	};

	utils = import ./utils.nix { inherit lib; };

	tdeo = import (builtins.fetchGit {
		url = "https://github.com/tadeokondrak/nix-overlay";
		rev = "0d05c53204da3b576f810ef2e1312b19bf2420b7";
	});

	diamond = ../nix-overlays;

in

{
	imports = [
		./hardware-configuration.nix
		./hardware-custom.nix
		"${diamond}"
		"${home-manager}/nixos"
	];

	# Overlays
	nixpkgs.overlays = [
		(tdeo)
		(self: super: {
			vte = super.vte.overrideAttrs(oldAttrs: {
				patches = oldAttrs.patches or [] ++ [ ./patches/vte-fast.patch ];
			});
			morph = super.morph.overrideAttrs(_: {
				version = "1.4.0";
				src = builtins.fetchGit {
					url = "https://github.com/diamondburned/morph.git";
					ref = "merges";
					rev = "a3ef469edf1613b8ab51de87e043c3c57d12a4a9";
				};
			});
			osu-wine = super.osu-wine.override {
				# Use Nixpkgs' 20.03 wine just so we don't have to recompile
				# lots.
				wine = super.wineStaging.overrideDerivation(old: {
					NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -DNDEBUG -Ofast -mfpmath=sse -mtune=intel -march=skylake";
					postPatch = (old.postPatch or "") + ''
						patch -Np1 < ${./patches/wine-4.2-alsa-lower-latency.patch}
						patch -Np1 < ${./patches/wine-4.2-pulseaudio-lower-latency.patch}
					'';
				});
			};
			# pulseaudio =
			# 	let overrideFn = old: {
			# 		NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -DNDEBUG -Ofast -mfpmath=sse -mtune=intel -march=skylake";
			# 	};
			# 	in           (super.pulseaudio.overrideAttrs(overrideFn)).override {
			# 		speexdsp = (super.speexdsp.overrideAttrs(overrideFn));
			# 	};
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
			maxJobs = 8; # thread-1
			speedFactor = 10;
			supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
		}];
		distributedBuilds = true;
		extraOptions = "builders-use-substitutes = true";
	};

	programs.ssh.extraConfig = ''
		Match Host hanaharu exec "nc -z 192.168.1.169 %p"
			HostName 192.168.1.169
		Match Host hanaharu
			HostName home.arikawa-hi.me
		Host hanaharu
			Port 1337
			User diamond
			IdentityFile   /home/diamond/.ssh/id_rsa
			IdentitiesOnly yes
			ServerAliveInterval 60
			ServerAliveCountMax 10
	'';

	# services.diamondburned.caddy = {
	# 	enable = true;
	# 	config = ''
	# 		http://127.0.0.1:28475 {
	# 			reverse_proxy * unix:///tmp/ghproxy.sock
	# 		}
	# 	'';
	# 	modSha256 = "07skcp85xvwak3pn7gavvclw9svps30yqgrsyfikhl6yspa9c45q";
	# };

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
		allowedTCPPorts = [ 22 ];
		allowedUDPPorts = [ 22 ];
	};

	i18n = {
		# inputMethod = {
		# 	enabled	= "fcitx";
		# 	fcitx.engines = with nixpkgs_19_09.fcitx-engines; [ mozc unikey ];
		# };

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
		htop
		git
	];

	# Install global fonts
	fonts.fonts = with pkgs; [
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji
		fira-code
		nerdfonts
		material-design-icons
		inconsolata
		comic-neue
		blobmoji
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
			gutenprint
			hplip
			cups-filters
			cups-bjnp
			cups-googlecloudprint

			# Canon
			cnijfilter2
			canon-cups-ufr2
		];
	};

	# Enable sound.
	sound.enable = true;
	hardware.pulseaudio = {
		enable = true;
		support32Bit = true;
		configFile = ./cfg/pulse_default.pa;
		daemon.config = {
			log-target = "newfile:/tmp/pulseaudio.log";
			daemonize = "yes";

			flat-volumes = "no";

			high-priority = "yes";
			nice-level = -15;

			realtime-scheduling = "yes";
			realtime-priority = 50;
			avoid-resampling = "yes";
			enable-lfe-remixing = "no";

			# resample-method = "speex-fixed-0";
			# resample-method = "copy";
			resample-method = "speex-float-2";
			default-sample-format = "float32le";
			default-sample-rate = "44100";
			alternate-sample-rate = "48000";

			default-fragments = 2;
			default-fragment-size-msec = 4;
  		};
		# Bluetooth shit
		package = pkgs.pulseaudioFull;
		extraModules = with pkgs; [
			pulseaudio-modules-bt
		];
	};
	nixpkgs.config.pulseaudio = true;

	# Enable the X11 windowing system.
	services.xserver.enable = true;
	services.xserver.layout = "us";
	services.xserver.xkbOptions = "caps:swapescape";

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

	# Enable touchpad support.
	services.xserver.libinput.enable = true;

	# Enable the GNOME desktop environment
	services.xserver.displayManager.gdm = {
		enable = true;
		wayland = true;
	};
	services.xserver.desktopManager.gnome3 = {
		enable = true;
		# sessionPath = with pkgs; [ gnome3.gpaste ];
	};
	# programs.xwayland.enable = true;

	# More GNOME things
	services.gnome3 = {
		# I like sushi (the food)
		# sushi.enable = true;

		# Enable the Keyring for password managing
		gnome-keyring.enable = true;

		# Online stuff
		gnome-online-accounts.enable = true;
		gnome-online-miners.enable = true;

		gnome-user-share.enable = true;
		chrome-gnome-shell.enable = true;

		# experimental-features.realtime-scheduling = true;
	};

	xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
	services.flatpak.enable = false;

	environment.gnome3.excludePackages = with pkgs.gnome3; [
		totem
		gnome-maps
		gnome-contacts
	];

    programs.seahorse.enable = true;

    services.gvfs.enable = true;
    programs.gpaste.enable = false;
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

	services.mpd = {
		enable = true;
		user = "diamond";
		group = "users";
		startWhenNeeded = true;
		dataDir = "/home/diamond/.local/share/mpd";
		musicDirectory = "/run/user/1000/gvfs/sftp:host=192.168.1.169,port=1337,user=diamond/mnt/Music";
		playlistDirectory = "/home/diamond/Music/playlists";
	};

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.diamond = {
		isNormalUser = true;
		extraGroups = [ "wheel" "networkmanager" "docker" "audio" "libvirtd" ];
	};

	home-manager.users.diamond = {
		imports = [
			"${lsoc-overlay}"
			"${diamond}/home-manager"
		];

		nixpkgs.config = {
			allowUnfree = true;
		};

		programs.direnv = {
			enable = true;
			enableNixDirenvIntegration = true;
		};

		services.lsoc-overlay = {
			enable = true;
			config = {
				red_blink_ms = 1000;
				polling_ms   = 1200;
				num_scanners = 1;
				window = {
					x = 5;
					y = 5;
					passthrough = true;
				};
			};
		};

		services.mpd = {
			enable = true;
		};

		programs.git = {
			enable = true;
			userName  = "diamondburned";
			userEmail = "datutbrus@gmail.com";
			extraConfig = {
				core = {
					excludesfile = "${pkgs.writeText "gitignore" ".envrc"}";
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
			# 	"breadcrumbs.enabled"       = false;
			# 	"editor.minimap.enabled"    = false;
			# };
		};

		programs.rhythmbox = {
			enable = true;
			plugins = with pkgs; [
				rhythmbox-alternative-toolbar
			];
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

		programs.firefox = {
			enable = true;
			profiles.default = import ./cfg/firefox;
		};

		gtk = {
			enable = true;
			font.name = "Sans";

			theme = {
				package = pkgs.materia-theme;
				name = "Materia-dark-compact";
			};

			iconTheme = {
				package = pkgs.papirus-icon-theme;
				name = "Papirus-Dark";
			};

			gtk3 = {
				extraConfig = {
					gtk-application-prefer-dark-theme = 1;
				};
				extraCss = builtins.readFile ./cfg/gtk.css;
			};
		};

		qt = {
			enable = true;
			platformTheme = "gnome";
		};

		dconf.settings = {
			"org/gnome/desktop/background" = {
				picture-uri = "${./background.jpg}";
			};
			"org/gnome/desktop/peripherals/keyboard" = {
				delay = 200;
				repeat-interval = 15;
			};
			"org/gnome/desktop/peripherals/mouse" = {
				middle-click-emulation = true;
			};
		};

		pam.sessionVariables = {
			NIX_AUTO_RUN = "1";
			GOPATH = "/home/diamond/.go";
			GOBIN  = "/home/diamond/.go/bin";

			# Disable VSync.
			vblank_mode = "0";

			# Enforce Wayland.
			QT_QPA_PLATFORM = "wayland";
			SDL_VIDEODRIVER = "wayland";
			MOZ_ENABLE_WAYLAND = "1";

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

		home = {
			# Custom overrides.
			packages = ([(
			# Neovim with yarn
				let neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs(old: {
					version = "0.5.0";
					src = builtins.fetchGit {
						url = "https://github.com/neovim/neovim.git";
						ref = "nightly";
						rev = "4f8d98e583beb4c1abd5d57b9898548396633030";
					};
				});
			
				in pkgs.wrapNeovim neovim-nightly {
					viAlias     = true;
					vimAlias    = true;
					withPython  = true;
					withPython3 = true;
					withNodeJs  = true;
					extraMakeWrapperArgs = "--suffix PATH : ${lib.makeBinPath (
						with pkgs; [ yarn ]
					)}";
				}
			)]) ++ (with pkgs.aspellDicts; [
				en
				en-science
				en-computers

			]) ++ (with pkgs; [
                # Personal stuff
				gnome3.gnome-usage
				gnome3.polari
				keepassx-community
				gnupg
				zoom-us
				bookworm
				gimp-with-plugins

				# Multimedia
				(enableDebugging ffmpeg)
				v4l_utils
				# mpv
				# audacious
				ymuse
				audacious-3-5
				pavucontrol
				pulseeffects

				# Development tools
				go
				clang-tools
				gotools
				nodePackages.eslint
				nodePackages.prettier
				xclip
				virt-manager

				# Web browser(s)
				# firefox
				google-chrome-dev
				fractal # lol
				tdesktop

				# Office
				evince
				typora
				bookworm

				# Dictionaries
				nuspell
				hunspell
				aspell

				# Applications
				gcolor3
				simplescreenrecorder

				# Themes
				materia-theme
				material-design-icons

				# Games
				osu-wine
				steam

				# GNOME things
				gnome-mpv
				gnome3.gnome-tweaks
				gnome3.glib-networking
				gnome3.file-roller
				gnome3.nautilus
				gnome3.gnome-boxes
				gnome3.gnome-disk-utility

				# GNOME extensions
				gnomeExtensions.gsconnect
				# gnomeExtensions.dash-to-panel
				gnomeExtensions.easyscreencast
				gnomeExtensions.remove-dropdown-arrows
			]);
		};

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

		programs.gnome-terminal.enable  = true;
		programs.gnome-terminal.profile = {
			"f2afd3c7-cb35-4d08-b6c2-523b444be64d" = {
				visibleName   = "pastel";
				showScrollbar = false;
				default = true;

				font	= "Inconsolata Bold 10";
				colors  = {
					backgroundColor = "#1D1D1D";
					foregroundColor = "#E5E5E5";
					palette = [
						"#272224" "#FF473D" "#3DCCB2" "#FF9600"
						"#3B7ECB" "#F74C6D" "#00B5FC" "#3E3E3E"

						"#52494C" "#FF6961" "#85E6D4" "#FFB347"
						"#779ECB" "#F7A8B8" "#55CDFC" "#EEEEEC"
					];
				};
			};
			"bade9a23-9fab-4bbb-9798-3dacbccd8e6c" = {
				visibleName  = "Google Light";
				showScrollbar = false;

				font   = "Inconsolata Bold 10";
				colors = {
					backgroundColor = "#FEFEFE";
					foregroundColor = "#373B41";
					palette = [
						"#1d1f21" "#cc342b" "#198844" "#fba922"
						"#3971ed" "#a36ac7" "#3971ed" "#c5c8c6"

						"#969896" "#cc342b" "#198844" "#fba922"
						"#3971ed" "#a36ac7" "#3971ed" "#252525"
					];
				};
			};
		};

		systemd.user.services.giomount = {
			Unit = {
				Description = "Auto-mount gio sftp mounts";
				After = "suspend.target";
			};
			Install = {
				WantedBy = [ "multi-user.target" ];
			};
			Service = {
				Type = "oneshot";
				ExecStart   = "${./bin/giomountall}";
				Environment = "PATH=${pkgs.gnugrep}/bin:${pkgs.bash}/bin:${pkgs.glib}/bin";
			};
		};

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
