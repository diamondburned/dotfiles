{ config, lib, pkgs, ... }:

let 
	unstable = import <nixpkgs> {
		config.allowUnfree = true;
		overlays = [(self: super: {
			go = super.go.overrideAttrs (old: {
				version = "1.17.2";
				src = builtins.fetchurl {
					url    = "https://golang.org/dl/go1.17.2.src.tar.gz";
					sha256 = "sha256:0cgla9vw2d3a12qnym1f663c2wa3af27ybnwzkaxfkc29qzfnm92";
				};
				doCheck = false;
			});
			obs-studio = super.obs-studio.overrideAttrs (old: {
				src = super.fetchFromGitHub {
					owner  = "obsproject";
					repo   = "obs-studio";
                    rev    = "cd5873e9bcfaf9cc2614939ddb3264bea919be4a";
					sha256 = "04fzsr9yizmxy0r7z2706crvnsnybpnv5kgfn77znknxxjacfhkn";
					fetchSubmodules = true;
				};

				version = "27.0.1";
				patches = [];

				cmakeFlags = old.cmakeFlags ++ [ "-Wno-error" "-DBUILD_BROWSER=false" ];
			});
		})];
	};

	# home-manager-master = builtins.fetchGit {
	# 	url = "https://github.com/nix-community/home-manager.git";
	# 	ref = "master";
	# };

	# Custom overrides.
	# Neovim with yarn.
	# neovim-nightly = pkgs.neovim-unwrapped.overrideAttrs(old: {
	# 	version = "v0.5.0-dev+1385-g93f15db5d";
	# 	src = pkgs.fetchFromGitHub {
	# 		owner  = "neovim";
	# 		repo   = "neovim";
	# 		rev    = "93f15db5d61800a2029aa20684be31c96ebcca5b";
	# 		sha256 = "1rk3q3qi0r40dwjd31q39vng47x55z31yjmyrmyhnl7rh8ds04ln";
	# 	};
	# 	# buildInputs = old.buildInputs ++ [ unstable.tree-sitter ];
	# 	buildInputs = old.buildInputs ++ [ pkgs.tree-sitter ];
	# });

	# ff-nightly =
	# 	let moz-url = builtins.fetchTarball {
	# 		url = "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz";
	# 	};
	# 	in (import "${moz-url}/firefox-overlay.nix"); 

	/*
	overlays = [
		# (ff-nightly)

		(self: super: {
			jack = super.jack2;

			# firefox-bin-unwrapped = unstable.firefox-bin-unwrapped.overrideAttrs(old: {
			# 	buildInputs = old.buildInputs ++ (with self; [
			# 		ffmpeg
			# 	]);
			# });
		})

		(self: super: {
			inherit (import <unstable> {})
				go
				gotools;

			inherit (unstable)
				easyeffects
				wf-config
				materia-theme
				papirus-icon-theme
				# fcitx5
				# fcitx5-m17n
				# fcitx5-mozc
				# fcitx5-with-addons
			;

			# pkgs.unstable
			# Doesn't work for some dumb reason.
			unstable = unstable;
			kakouneUtils = unstable.kakouneUtils;

			neovim = pkgs.wrapNeovim neovim-nightly {
				viAlias     = false; # in case
				vimAlias    = false;
				withPython3 = true;
				withNodeJs  = true;
				extraMakeWrapperArgs = "--suffix PATH : ${lib.makeBinPath (
					with super; [ yarn ]
				)}";
			};
		})
	];
	*/

in {
	/*
	imports = [
		# <unstable/nixos/modules/i18n/input-method/default.nix>
		# <unstable/nixos/modules/i18n/input-method/fcitx5.nix>
		<unstable/nixos/modules/services/desktops/pipewire/pipewire.nix>
		<unstable/nixos/modules/services/desktops/pipewire/pipewire-media-session.nix>
	];
	disabledModules = [
		"services/desktops/pipewire.nix"
		"services/desktops/pipewire/pipewire.nix"
		"services/desktops/pipewire/pipewire-media-session.nix"
		# "i18n/input-method/default.nix"
	];

	services.pipewire = {
		package = unstable.pipewire;
		media-session = {
			package = unstable.pipewire.mediaSession;
		};
	};

	# i18n.inputMethod = {
	# 	enabled	= "fcitx5";
	# 	fcitx5.addons = with unstable; [
	# 		fcitx5-m17n
	# 		fcitx5-mozc
	# 	];
	# };

	# Real-time Linux 5.11.
	# boot.kernelPackages = unstable.linuxPackages-rt_5_11;
	*/

	# For Steam.
	# hardware.opengl.extraPackages32 = with unstable.pkgsi686Linux; [
	# 	libva
	# 	pipewire.lib
	# ];

	environment.systemPackages = with pkgs; [
		htop

		materia-theme
		papirus-icon-theme
	];

	programs.steam.enable = true;

	home-manager.users.diamond = {
		# programs.mpv.package = unstable.mpv;
		# programs.firefox.package = unstable.firefox-bin // {
		# 	browserName = "firefox";
		# };
		# programs.vscode-css.package = unstable.vscode.overrideAttrs(old: {
		# 	buildInputs = old.buildInputs ++ [ pkgs.makeWrapper ];
		# 	postInstall = ''
		# 		wrapProgram $out/bin/code --add-flags \
		# 			"--enable-features=UseOzonePlatform --ozone-platform=wayland"
		# 	'';
		# });

		# programs.obs-studio.package = unstable.obs-studio;

		# gtk.theme.package = unstable.materia-theme;
		# gtk.iconTheme.package = unstable.papirus-icon-theme;

		# nixpkgs.overlays = overlays;

		home.packages = with pkgs; [
			# sage
			abiword
			darktable

			# Typing
			fcitx5-configtool
			fcitx5-gtk

			# Compilers
			unstable.go

			playerctl
			wl-clipboard
		];
	};

	# nixpkgs.overlays = [ (self: super: {
	# 	neovim = pkgs.wrapNeovim neovim-nightly {
	# 		viAlias     = false; # in case
	# 		vimAlias    = false;
	# 		withPython3 = true;
	# 		withNodeJs  = true;
	# 		extraMakeWrapperArgs = "--suffix PATH : ${lib.makeBinPath (
	# 			with super; [ yarn ]
	# 		)}";
	# 	};
	# }) ];
}
