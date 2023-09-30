self: super: {
	transmission-web = super.callPackage ./packages/transmission-web {};
	audacious-3-5 = super.callPackage ./packages/audacious-3-5 {};
	ytmdesktop = super.callPackage ./packages/ytmdesktop.nix {};
	tagtool  = super.callPackage ./packages/tagtool.nix {};
	ymuse    = super.callPackage ./packages/ymuse {};
	srain    = super.callPackage ./packages/srain {};
	caddy    = super.callPackage ./packages/caddy {};
	xcaddy   = super.callPackage ./packages/xcaddy {};
	caddyv1  = super.callPakcage ./packages/caddyv1 {};
	vkmark   = super.callPackage ./packages/vkmark {};
	aqours   = super.callPackage ./packages/aqours {};
	ghproxy  = super.callPackage ./packages/ghproxy {};
	openmoji = super.callPackage ./packages/openmoji {};
	blobmoji = super.callPackage ./packages/blobmoji {};
	drone-ci = super.callPackage ./packages/drone-ci {};
	gappdash = super.callPackage ./packages/gappdash {};
	gotktrix = super.callPackage ./packages/gotktrix.nix {};
	gtkcord4 = super.callPackage ./packages/gtkcord4.nix {};
	osu-wine = super.callPackage ./packages/osu-wine {};
	osu-wineprefix = super.callPackage ./packages/osu-wineprefix {};
	neovim-gtk = super.callPackage ./packages/neovim-gtk {
		inherit (super.nixpkgs_unstable_newer) rustPlatform;
	};
	gotab = super.callPackage ./packages/gotab.nix {};
	oxfs = super.callPackage ./packages/oxfs.nix {};
	gpt4all = super.qt6Packages.callPackage ./packages/gpt4all.nix {};
	nix-search = super.callPackage ./packages/nix-search.nix {};
	inconsolata = super.callPackage ./packages/inconsolata.nix {};
	intiface-cli = super.callPackage ./packages/intiface-cli {};
	catnip-gtk = super.callPackage ./packages/catnip-gtk {};
	passwordsafe = super.callPackage ./packages/gnome-passwordsafe {};
	google-chrome-ozone = super.callPackage ./packages/google-chrome-ozone {};
	lightdm-elephant-greeter = super.callPackage ./packages/lightdm-elephant-greeter;
	rhythmbox-alternative-toolbar = super.callPackage ./packages/rhythmbox-alternative-toolbar {};
	perf_data_converter = super.callPackage ./packages/perf_data_converter.nix {};
	typescript-transpile-only = super.callPackage ./packages/typescript-transpile-only {};
	xelfviewer = super.callPackage (builtins.fetchurl "https://raw.githubusercontent.com/xieby1/nix_config/fedd0cbdc5e49b55768d9fc3781e47f66f8e5e04/usr/gui/xelfviewer.nix") {};
	# gnomeExtensions = super.gnomeExtensions // {
	# 	easyscreencast = super.callPackage ./packages/gnome-extensions/easyscreencast {};
	# };
}
