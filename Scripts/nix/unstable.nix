{ config, lib, pkgs, ... }:

let unstable = import <unstable> {
		config.allowUnfree = true;
	};

	# home-manager-master = builtins.fetchGit {
	# 	url = "https://github.com/nix-community/home-manager.git";
	# 	ref = "master";
	# };

	# Custom overrides.
	# Neovim with yarn.
	neovim-nightly = unstable.neovim-unwrapped.overrideAttrs(old: {
		version = "v0.5.0-dev+1345-g6dd04ed5f";
		src = pkgs.fetchFromGitHub {
			owner  = "neovim";
			repo   = "neovim";
			rev    = "6dd04ed5f6c0b68eed38aeb2a3f930d8d6353678";
			sha256 = "02cc98s7kgxg8g2zp9d80s8a853h4b3vm5zxby1rcg85rfpkmab7";
		};
		buildInputs = old.buildInputs ++ [ unstable.tree-sitter ];
	});

	ff-nightly =
		let moz-url = builtins.fetchTarball {
			url = "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz";
		};
		in (import "${moz-url}/firefox-overlay.nix"); 

	overlays = [
		(ff-nightly)

		(self: super: {
			jack = super.jack2;

			firefox-bin-unwrapped = super.firefox-bin-unwrapped.overrideAttrs(old: {
				buildInputs = old.buildInputs ++ (with self; [
					ffmpeg
				]);
			});
		})

		(self: super: {
			inherit (unstable)
				go
				gotools
				pulseeffects-pw
				wf-config
				materia-theme
			;

			# pkgs.unstable
			# Doesn't work for some dumb reason.
			unstable = unstable;
			kakouneUtils = unstable.kakouneUtils;

			neovim = unstable.wrapNeovim neovim-nightly {
				viAlias     = false; # in case
				vimAlias    = false;
				withPython  = true;
				withPython3 = true;
				withNodeJs  = true;
				extraMakeWrapperArgs = "--suffix PATH : ${lib.makeBinPath (
					with super; [ yarn ]
				)}";
			};
		})
	];

in {
	imports = [
		<unstable/nixos/modules/services/desktops/pipewire/pipewire.nix>
		<unstable/nixos/modules/services/desktops/pipewire/pipewire-media-session.nix>
	];
	disabledModules = [
		"services/desktops/pipewire.nix"
	];

	services.pipewire = {
		package = unstable.pipewire;
		media-session = {
			package = unstable.pipewire.mediaSession;
		};
	};

	# Real-time Linux 5.11.
	# boot.kernelPackages = unstable.linuxPackages-rt_5_11;

	home-manager.users.diamond = {
		programs.mpv.package = unstable.mpv;
		programs.firefox.package = pkgs.latest.firefox-beta-bin // {
			browserName = "firefox";
		};
		programs.vscode-css.package = unstable.vscode.overrideAttrs(old: {
			buildInputs = old.buildInputs ++ [ pkgs.makeWrapper ];
			postInstall = ''
				wrapProgram $out/bin/code --add-flags \
					"--enable-features=UseOzonePlatform --ozone-platform=wayland"
			'';
		});

		nixpkgs.overlays = overlays;

		home.packages = with unstable; [
			sage
			abiword
			darktable
		];
	};

	nixpkgs.overlays = overlays;
}
