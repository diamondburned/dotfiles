self: super:

let lib = super.lib;

	vte = pkgs: pkgs.vte.overrideAttrs(old: {
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

	spicetify = builtins.fetchTarball https://github.com/pietdevries94/spicetify-nix/archive/master.tar.gz;
	spicetify-themes = builtins.fetchTarball https://github.com/morpheusthewhite/spicetify-themes/archive/master.tar.gz;

	GOPATH = "/home/diamond/.go";

in {
	# Upgrades.
	inherit (self.nixpkgs_unstable)
		neovim
		go_1_18;

	# inherit (nixpkgs_pipewire_0_3_57)
	# 	pipewire;

	# Downgrades.
	# inherit (self.nixpkgs_21_11)
	# 	gnome;

	# For Copilot + Vim.
	nixpkgs_copilot = import <nixpkgs> {
		overlays = [
			(self_copilot: super_copilot: {
				nodejs = self.nixpkgs_21_11.nodejs;
			})
		];
	};

	# I don't care!!!!!! Nixpkgs, stop doing this!!
	pkgconfig = self.pkg-config;

	sommelier = super.sommelier.overrideAttrs (old: {
		version = "110.0";
		src = super.fetchzip rec {
			url = "https://chromium.googlesource.com/chromiumos/platform2/+archive/${passthru.rev}/vm_tools/sommelier.tar.gz";
			passthru.rev = "fc06d8652e47afb3cd94f8fb5f09f740d72456c2";
			stripRoot = false;
			sha256 = "0vmy4jjid68l5cjv8sdwn45vzisl64czxlj2j509glwa5alw8pvn";
		};
	});

	# For OBS.
	# inherit (nixpkgs_puffnfresh)
	# 	obs-studio
	# 	obs-studio-plugins;

	# mpv-next = let
	# 	super_unstable = super.nixpkgs_unstable_real;
	# 	# ffmpeg = super_unstable.ffmpeg.overrideAttrs(old: {
	# 	# 	src = super.fetchFromGitHub {
	# 	# 		owner  = "FFmpeg";
	# 	# 		repo   = "FFmpeg";
	# 	# 		rev    = "n5.1.2";
	# 	# 		sha256 = "sha256-0Q4Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7=";
	# 	# 	};
	# 	# });
	# 	libplacebo = super_unstable.libplacebo.overrideAttrs (old: {
	# 		version = "master-deccd2c";

	# 		src = super.fetchFromGitLab {
	# 			domain = "code.videolan.org";
	# 			owner  = "videolan";
	# 			repo   = "libplacebo";
	# 			rev    = "deccd2c7cc0a6d26f7649273d5c6878e255e1ac3";
	# 			sha256 = "1p0y4q68jgds81n3rv4lhsgip66ybsw21v1b770lag61z8lbyshl";
	# 		};
	# 	});
	# 	mpv-unwrapped' = super_unstable.mpv-unwrapped.override {
	# 		inherit libplacebo;
	# 		# ffmpeg = super_unstable.ffmpeg_5;
	# 	};
	# 	mpv-unwrapped = super_unstable.mpv-unwrapped.overrideAttrs (old: {
	# 		version = "master-b9c7e5b";

	# 		src = super.fetchFromGitHub {
	# 			owner  = "mpv-player";
	# 			repo   = "mpv";
	# 			rev    = "b9c7e5b5fff88c86ed19c9753b3b8a2499293bee";
	# 			sha256 = "1wf6xpbvcfchmc6442sqdzdglsv57ynpr63bg8vj7iz0y70k8kgq";
	# 		};
	# 	});
	# 	in super_unstable.wrapMpv mpv-unwrapped {};

	# OBS junk.
	# onnxruntime = self.callPackage <nixpkgs/pkgs/development/libraries/onnxruntime> { };
	obs-backgroundremoval = self.callPackage <nixpkgs_puffnfresh/pkgs/applications/video/obs-studio/plugins/obs-backgroundremoval.nix> {};

	# SPEEEEEEN.
	libqalculate = super.libqalculate.override {
		stdenv = super.impureUseNativeOptimizations super.stdenv;
	};

	buildLocalGoModule = { GOPATH ? GOPATH, ... }@args: super.buildGoModule {
		vendorSha256 = null;
		postConfigure = ''
			export GOPATH=${GOPATH}
			${args.postConfigure or ""}
		'';
	};

	gnome = super.gnome.overrideScope' (self_gnome: super_gnome: {
		mutter = super_gnome.mutter.overrideAttrs (old: {
			patches = (old.patches or []) ++ [
				# Allow 10 scale factors per integer instead of 4.
				./patches/mutter-scale-factors.patch
				# Support the Xwayland MR underneath by changing the X scale factor to 2x.
				# ./patches/mutter-xserver-scale-2x.diff
			];
			doCheck = false;
		});
	});

	# xwayland = super.xwayland.overrideAttrs (old: {
	# 	# https://gitlab.freedesktop.org/xorg/xserver/-/merge_requests/733
	# 	src = super.fetchFromGitLab {
	# 		domain = "gitlab.freedesktop.org";
	# 		owner  = "refi_64";
	# 		repo   = "xserver";
	# 		rev    = "01513cd124576167ec802e43e952d33476ce0d32"; # scaling-mr
	# 		sha256 = "0n1c1wrg3mqqvhn265qjbmfmch6ii9n419yyalwdib2abxfba7cj";
	# 	};
	# 	buildInputs = old.buildInputs ++ (with super; [
	# 		udev
	# 		xorg.libpciaccess
	# 	]);
	# 	patches = (old.patches or []) ++ [
	# 		# Hack to use 2x scaling always. Fits my purpose.
	# 		./patches/xserver-scale-2x.diff
	# 	];
	# 	doCheck = false;
	# });

	# Fuck libadwaita's stylesheets. They can go fuck themselves.
	fuck-libadwaita = pkg: self.fuck-libadwaita-bin pkg pkg.pname;

	fuck-libadwaita-bin = pkg: bin:
		let adw = super.libadwaita.overrideAttrs (old: {
			name = "libadwaita-nocss";
			doCheck = false;
			postPatch = (old.postPatch or "") + ''
				patch -N -p1 < ${./patches/libadwaita-nocommon.patch}
				# sed -i 's/g_getenv ("GTK_THEME")/TRUE/g' $(find . -name '*.c')
			'';
		});
		in super.writeScriptBin bin ''
			export LD_PRELOAD=${adw}/lib/libadwaita-1.so
			exec ${pkg}/bin/${bin} "$@"
		'';
	
	succumb-to-libadwaita = pkg: self.succumb-to-libadwaita-bin pkg pkg.pname;
	
	succumb-to-libadwaita-bin = pkg: bin: super.writeScriptBin bin ''
		unset GTK_THEME
		exec ${pkg}/bin/${bin} "$@"
	'';

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
	vscode = super.nixpkgs_unstable.vscode;
	# vscode = super.vscode.overrideAttrs(old: {
	# 	nativeBuildsInputs = (old.nativeBuildInputs or []) ++ [
	# 		super.makeWrapper
	# 	];
	# 	postFixup = (old.postFixup or "") + ''
	# 		wrapProgram $out/bin/code \
	# 			--add-flags "--enable-features=UseOzonePlatform" \
	# 			--add-flags "--ozone-platform=wayland"
	# 	'';
	# });
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
		let version = "0.0.21";
			asar = builtins.fetchurl {
				url    = "https://github.com/GooseMod/OpenAsar/releases/download/nightly/app.asar";
				sha256 = "16191zzhqab0cq79vcvynw26gmq87z5ig0qzjmsygp2kkdb0yzdw";
			};
		in {
			inherit version;
			src = super.fetchurl {
				url    = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
				sha256 = "18rmw979vg8lxxvagji6sim2s5yyfq91lfabsz1wzbniqfr98ci8";
			};
			# buildInputs = (old.buildInputs or []) ++ [ super.unzip ];
			# nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ super.makeWrapper ]; 
			postFixup = (old.postFixup or "") + ''
				# cp ${asar} $out/opt/Discord/resources/app.asar
				wrapProgram $out/bin/discord \
					--add-flags "--enable-gpu-rasterization --enable-zero-copy --enable-gpu-compositing --enable-native-gpu-memory-buffers --enable-oop-rasterization --enable-features=UseSkiaRenderer,CanvasOopRasterization"
			'';
		});

	makeFirefoxProfileDesktopFile = {
		profile,
		name ? "Firefox (${profile})",
		icon ? "firefox",
	}: super.makeDesktopItem {
		name = "firefox-${profile}.desktop";
		# bin/find-desktop Firefox
		desktopName = name;
		genericName = "Web Browser (${name})";
		exec = "firefox -p ${profile} %U";
		icon = icon;
		mimeTypes = [
			"text/html"
			"text/xml"
			"application/xhtml+xml"
			"application/vnd.mozilla.xul+xml"
			"x-scheme-handler/http"
			"x-scheme-handler/https"
			"x-scheme-handler/ftp"
		];
		categories = [ "Network" "WebBrowser" ];
	};
}
