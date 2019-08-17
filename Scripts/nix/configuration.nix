# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let home-manager = builtins.fetchGit {
	url = "https://github.com/rycee/home-manager.git";
	rev = "8b15f1899356762187ce119980ca41c0aba782bb";
	ref = "master";
};

in

{
	imports = [
		./hardware-configuration.nix
		"${home-manager}/nixos"
	];

	# Overlays
	nixpkgs.overlays = [ 
		(self: super: {
			vte = super.vte.overrideAttrs (oldAttrs: {
				patches = oldAttrs.patches or [] ++ [ ./patches/vte-fast.patch ];
			});
		})
	];

	# Latest kernel
	# boot.kernelPackages = pkgs.linuxPackages_5_1;

	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	zramSwap = {
		enable = true;
		algorithm = "lz4";
		memoryPercent = 25;
	};

	networking.hostName = "hackadoll3"; # Define your hostname.
	networking.networkmanager.enable = true;
	networking.nameservers = [
		"1.1.1.1" "1.0.0.1"
	];
	networking.extraHosts = 
		let
			inherit (lib) concatStringsSep;
			inherit (builtins) readFile fetchurl;
			lists = [
				https://adaway.org/hosts.txt
				https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Hosts/GoodbyeAds.txt
				https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
				https://mirror1.malwaredomains.com/files/justdomains
				http://sysctl.org/cameleon/hosts
				https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist
				https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt
				https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
				https://zerodot1.gitlab.io/CoinBlockerLists/hosts
				https://hosts-file.net/ad_servers.txt
			];
		in concatStringsSep "\n" (map readFile (map fetchurl lists));


	i18n = {
		inputMethod = {
			enabled	= "fcitx";
			fcitx.engines = with pkgs.fcitx-engines; [ mozc unikey ];
		};

		consoleFont = "Lat2-Terminus16";
		consoleKeyMap = "us";
		defaultLocale = "en_US.UTF-8";
		supportedLocales = [
			"en_US.UTF-8/UTF-8"
			"ja_JP.UTF-8/UTF-8"
			"vi_VN/UTF-8"
		];
	};

	# Set your time zone.
	time.timeZone = "America/Los_Angeles";

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment.systemPackages = with pkgs; [
		# System packages
		wget

		# Utilities
		htop
		git

		# Multimedia
		ffmpeg
		mpv
	];

	# Install global fonts
	fonts.fonts = with pkgs; [
		noto-fonts
		noto-fonts-cjk
		noto-fonts-emoji
		fira-code
		material-design-icons
	];

	# Global environment variables
	environment.variables = {
		# Setup Golang
		GOROOT = [ "${pkgs.go_1_12.out}/share/go" ];
	};

    # Battery saver thing
    services.tlp.enable = true;

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	programs.mtr.enable = true;
	programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	services.openssh.enable = true;

	# Enable CUPS to print documents.
	services.printing.enable = true;

	# Enable sound.
	sound.enable = true;
	hardware.pulseaudio.enable = true;

	# Enable the X11 windowing system.
	services.xserver.enable = true;
	services.xserver.layout = "us";

	# Enable touchpad support.
	services.xserver.libinput.enable = true;

	# Enable the GNOME desktop environment
	services.xserver.displayManager.gdm.enable = true;
	services.xserver.desktopManager.gnome3.enable = true;

	# More GNOME things
	services.gnome3 = {
		# I like sushi (the food)
		sushi.enable = true;

		# Seahorse for password managing
		seahorse.enable = true;

		# Enable the GNOME Virtual File System
		gvfs.enable = true;

		# Enable the GPaste clipboard manager
		gpaste.enable = true;

		# Enable the Keyring for password managing
		gnome-keyring.enable = true;

		# Online stuff
		gnome-online-accounts.enable = true;
		gnome-online-miners.enable = true;

		gnome-user-share.enable = true;
		gnome-disks.enable = true;
		file-roller.enable = true;
		chrome-gnome-shell.enable = true;
	};

	# dbus things
	services.xserver.startDbusSession = true;
	services.dbus.socketActivated = true;
	services.dbus.packages = with pkgs; [ gnome3.dconf ];

	# Enable Polkit
	security.polkit.enable = true;

    /*
	# Enable MySQL
	services.mysql = {
		enable = true;
		package = pkgs.mariadb;
    };
    */

    services.postgresql.enable = true;

	# Define a user account. Don't forget to set a password with ‘passwd’.
	users.users.diamond = {
		isNormalUser = true;
		extraGroups = [ "wheel" "networkmanager" "docker" "audio" ];
	};

	home-manager.users.diamond = {
		programs.git = {
			enable = true;
			userName = "diamondburned";
			userEmail = "datutbrus@gmail.com";
		};

		programs.neovim = {
			enable = true;
			vimAlias = true;
			withPython3 = true;
		};
	
		programs.bash = {
			enable = true;
			shellAliases = {
				nixrl = "sudo nixos-rebuild --upgrade switch";
				nixsh = "nix-shell '<nixpkgs>' -p";
				gr = "go run .";
				ga = "git add -A";
				gm = "git commit -m";
				gp = "git push origin";
			};
			initExtra = ''
				export PS1="\[\033[00;35m\]''${HOSTNAME} \[\033[01;31m\]\w/ \[\033[0m\]"
			'';
		};

		programs.mpv = {
			enable = true;
			config = {
				osd-font = "Sans";
				profile = "gpu-hq";
				gpu-api = "opengl";
				gpu-context = "auto";
				vo = "gpu";
				dither-depth = 8;
				fbo-format = "rgba32f";
				scale = "ewa_lanczos";
			};
		};

		gtk = {
			enable = true;
			font.name = "Noto Sans UI";

			theme = {
				package = pkgs.materia-theme;
				name = "Materia-dark";
			};

			iconTheme = {
				package = pkgs.papirus-icon-theme;
				name = "Papirus-Dark";
			};

			gtk3 = {
				extraConfig = {
					gtk-application-prefer-dark-theme = 1;
				};
				extraCss = ''
					vte-terminal {
						padding: 4px 8px;
					}
				'';
			};
		};

		qt = {
			enable = true;
			useGtkTheme = true;
		};

		nixpkgs.config = {
			allowUnfree = true;
		};

		home = {
			sessionVariables = {
				NIX_AUTO_RUN = [ "1" ];
				GOPATH = [ "/home/diamond/.go" ];
				GOBIN  = [ "/home/diamond/bin" ];
			};

			packages = with pkgs; [
                # Personal stuff
                gimp-with-plugins

				# Development tools
				go_1_12
				gotools
				xclip

				# Web browser(s)
				chromium

				# Office
				evince

				# Why the fuck not
				# muh ligmatures
				konsole

				# Applications
				gcolor3
				simplescreenrecorder

				# Themes
				materia-theme
				material-design-icons

				# GNOME things
				gnome-mpv
				gnome3.gnome-tweaks
				gnome3.glib-networking
				gnome3.file-roller
				gnome3.nautilus
				gnome3.gnome-disk-utility

				# GNOME extensions
				gnomeExtensions.dash-to-panel
				gnomeExtensions.battery-status
				gnomeExtensions.caffeine
				gnomeExtensions.clipboard-indicator
				gnomeExtensions.no-title-bar
				gnomeExtensions.nohotcorner
				gnomeExtensions.remove-dropdown-arrows
				gnomeExtensions.impatience
			];
		};

		dconf.settings = {
			"org/gnome/desktop/peripherals/keyboard" = {
				delay = 200;
				repeat-interval = 20;
			};
            "org/gnome/mutter" = {
                experimental-features = [ "scale-monitor-framebuffer" ];
            };
		};

		xdg = {
			enable = true;
			configFile = {
				# Allow non-free for user
				"nixpkgs/config.nix".text = ''builtins.fromJSON '''${builtins.toJSON {
					allowUnfree = true;
				}}''''';
				"fontconfig/fonts.conf".source = ./cfg/fontconfig.xml;
				"nvim/init.vim".source = ./cfg/nvimrc;
			};
		};
	};

	system.stateVersion = "19.03"; # DO NOT TOUCH
}
