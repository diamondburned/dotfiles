self: super:

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
	nur = import
		(builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz")
		{pkgs = super;};

	spicetify = builtins.fetchTarball https://github.com/pietdevries94/spicetify-nix/archive/master.tar.gz;
	spicetify-themes = builtins.fetchTarball https://github.com/morpheusthewhite/spicetify-themes/archive/master.tar.gz;

	nixpkgs_21_11 = import <nixpkgs_21_11> { config.allowUnfree = true; };
	nixpkgs_unstable = import <nixpkgs_unstable> { config.allowUnfree = true; };
	nixpkgs_puffnfresh = import <nixpkgs_puffnfresh> { config.allowUnfree = true; };

	GOPATH = "/home/diamond/.go";

in {
	# Expose these for the system to use.
	inherit
		nixpkgs_21_11
		nixpkgs_unstable;

	# Upgrades.
	inherit (nixpkgs_unstable)
		neovim
		go_1_18;

	# Downgrades.
	# inherit (nixpkgs_21_11);

	# For OBS.
	# inherit (nixpkgs_puffnfresh)
	# 	obs-studio
	# 	obs-studio-plugins;

	# OBS junk.
	onnxruntime = self.callPackage <nixpkgs_puffnfresh/pkgs/development/libraries/onnxruntime> { };
	obs-backgroundremoval = self.callPackage <nixpkgs_puffnfresh/pkgs/applications/video/obs-studio/plugins/obs-backgroundremoval.nix> {};

	buildLocalGoModule = { GOPATH ? GOPATH, ... }@args: super.buildGoModule {
		vendorSha256 = null;
		postConfigure = ''
			export GOPATH=${GOPATH}
			${args.postConfigure or ""}
		'';
	};

	# NUR
	gamescope = nur.repos.dukzcry.gamescope;
	spotify-adblock = nur.repos.instantos.spotify-adblock;
	gatttool = nur.repos.mic92.gatttool;

	# Spotify
	spotify-unwrapped = self.callPackage ./packages/spotify-adblocked.nix {
		curl = super.curl.override {
			gnutlsSupport  = true;
			# sslSupport = false;
			opensslSupport = false;
		};
	};
	spotify = self.callPackage "${super.path}/pkgs/applications/audio/spotify/wrapper.nix" {
		inherit (self) spotify-unwrapped;
	};

	gotktrix = self.callPackage ./packages/gotktrix.nix {};
	grun     = self.callPackage ./packages/grun.nix {};

	wlroots = super.wlroots.overrideAttrs(old: {
		version = "cyanreg-f21245b";
		src = super.fetchFromGitHub {
			owner  = "cyanreg";
			repo   = "wlroots";
			rev    = "f21245b";
			sha256 = "1395940dq75bl9ipvms5hkmz5km0jl3bh37k2a21ld4mprpqhvz3";
		};
		# patches = (old.patches or []) ++ (with builtins; [
		# 	(fetchurl "https://github.com/cyanreg/wlroots/commit/f21245b03a459d74187cf05e8ad531c2bf07cc42.patch")
		# ]);
	});

	# Broken
	# spotify = self.callPackage (import "${spicetify}/package.nix") {
	# 	theme = "Fluent";
	# 	colorScheme = "Dark";
	# 	thirdParyThemes = {
	# 		"Fluent" = "${spicetify-themes}/Fluent";
	# 	};
	# };

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
	# morph = super.morph.overrideAttrs(_: {
	# 	version = "1.4.0";
	# 	src = builtins.fetchGit {
	# 		url = "https://github.com/diamondburned/morph.git";
	# 		ref = "merges";
	# 		rev = "a3ef469edf1613b8ab51de87e043c3c57d12a4a9";
	# 	};
	# });
	osu-wine-realistik = super.writeShellScriptBin "osu-realistik" ''
		${self.osu-wine}/bin/osu -devserver ussr.pl "$@"
	'';
	# Omitted because it's too much to compile.
	# osu-wine = super.osu-wine.override {
	# 	wine = aspellPkgs.wineStaging.overrideDerivation(old: {
	# 		NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -DNDEBUG -Ofast -mfpmath=sse -mtune=intel -march=skylake";
	# 		postPatch = (old.postPatch or "") + ''
	# 			patch -Np1 < ${../patches/wine-4.2-alsa-lower-latency.patch}
	# 			patch -Np1 < ${../patches/wine-4.2-pulseaudio-lower-latency.patch}
	# 		'';
	# 	});
	# };
	materia-theme = super.materia-theme.overrideAttrs(old: {
		version = "20210322";
		src = super.fetchFromGitHub {
			owner  = "nana-4";
			repo   = "materia-theme";
			rev    = "v20210322";
			sha256 = "1fsicmcni70jkl4jb3fvh7yv0v9jhb8nwjzdq8vfwn256qyk0xvl";
		};
	});
	vscode = super.vscode.overrideAttrs(old: {
		nativeBuildsInputs = (old.nativeBuildInputs or []) ++ [
			super.makeWrapper
		];
		postFixup = (old.postFixup or "") + ''
			wrapProgram $out/bin/code \
				--add-flags "--enable-features=UseOzonePlatform" \
				--add-flags "--ozone-platform=wayland"
		'';
	});
	octave-soft = super.writeShellScriptBin "octave" ''
		export LIBGL_ALWAYS_SOFTWARE=true
		${super.octaveFull}/bin/octave "$@"
	'';
	blueberry = super.blueberry.override {
		gnome = super.gnome.overrideScope' (gself: gsuper: {
			gnome-bluetooth = gsuper.gnome-bluetooth.overrideAttrs(old: {
				postPatch = (old.postPatch or "") + ''
		 			patch -Np1 < ${../patches/gnome-bluetooth-connectall.patch}
				'';
			});
		});
	};
	# octave-soft = super.buildEnv {
	# 	name = "octave-soft";
	# 	paths = with super; [ octave ];
	# 	nativeBuildInputs = with super; [ makeWrapper ];
	# 	postBuild = ''
	# 		wrapProgram $out/bin/octave --set LIBGL_ALWAYS_SOFTWARE true
	# 	'';
	# };
	# octave-soft = super.octave.overrideAttrs(old: {
	# 	# Workaround for working anti-aliasing.
	# 	# https://savannah.gnu.org/bugs/?55224
	# 	postFixup = (old.postFixup or "") + ''
	# 		wrapProgram $out/bin/octave --set LIBGL_ALWAYS_SOFTWARE true
	# 	'';
	# });

	discord = super.discord.overrideAttrs (old:
		let version = "0.0.18";
			asar = builtins.fetchurl {
				url    = "https://github.com/GooseMod/OpenAsar/releases/download/nightly/app.asar";
				sha256 = "16191zzhqab0cq79vcvynw26gmq87z5ig0qzjmsygp2kkdb0yzdw";
			};
		in {
			inherit version;
			src = super.fetchurl {
				url    = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
				sha256 = "1hl01rf3l6kblx5v7rwnwms30iz8zw6dwlkjsx2f1iipljgkh5q4";
			};
			# buildInputs = (old.buildInputs or []) ++ [ super.unzip ];
			# nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ super.makeWrapper ]; 
			postFixup = (old.postFixup or "") + ''
				# cp ${asar} $out/opt/Discord/resources/app.asar
				wrapProgram $out/bin/discord \
					--add-flags "--enable-gpu-rasterization --enable-zero-copy --enable-gpu-compositing --enable-native-gpu-memory-buffers --enable-oop-rasterization --enable-features=UseSkiaRenderer,CanvasOopRasterization"
			'';
		});
}