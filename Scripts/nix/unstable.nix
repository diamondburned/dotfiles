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
		version = "v0.5.0-dev+1233-g82ac44d01";
		src = pkgs.fetchFromGitHub {
			owner  = "neovim";
			repo   = "neovim";
			rev    = "82ac44d01f0e92546f43c804595c14a139af77bd";
			sha256 = "1n89wb18zg89dya4fcd345kmkbflh9jl571adffzy4psn6zqq1c9";
		};
		buildInputs = old.buildInputs ++ [ unstable.tree-sitter ];
	});

	ff-nightly =
		let moz-url = builtins.fetchTarball {
			url = "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz";
		};
		in (import "${moz-url}/firefox-overlay.nix"); 

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
	boot.kernelPackages = unstable.linuxPackages-rt_5_11;

	home-manager.users.diamond = {
		programs.mpv.package = unstable.mpv;
		programs.firefox.package = pkgs.latest.firefox-nightly-bin // {
			browserName = "firefox";
		};

		home.packages = with unstable; [
			sage
		];
	};

	nixpkgs.overlays = [
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
		
			neovim = unstable.wrapNeovim neovim-nightly {
				viAlias     = false; # in case
				vimAlias    = true;
				withPython  = true;
				withPython3 = true;
				withNodeJs  = true;
				extraMakeWrapperArgs = "--suffix PATH : ${lib.makeBinPath (
					with super; [ yarn ]
				)}";
			};
		})

		# Use the Firefox Nightly overlay with the latest unstable packages.
		(ff-nightly)
	];
}
