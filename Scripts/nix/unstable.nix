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
	# boot.kernelPackages = pkgs.linuxPackages-rt_5_11;

	home-manager.users.diamond = {
		programs.mpv.package = unstable.mpv;
	};

	nixpkgs.overlays = [
		(self: super: {
			jack = super.jack2;
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
	];
}
