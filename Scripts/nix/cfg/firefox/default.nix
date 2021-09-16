{ config, lib, pkgs, ... }:

let profileName = "default";
	profilePath = "q1f740f8.default";

	nativeMessagingHosts = {
		"org.gnome.shell.extensions.gsconnect" = pkgs.gnomeExtensions.gsconnect;
		"org.gnome.chrome_gnome_shell"         = pkgs.chrome-gnome-shell;
	};

	firefox-attrs = {
		applicationName = "firefox";
		forceWayland = true;
		extraNativeMessagingHosts = lib.attrValues nativeMessagingHosts;
	};

	firefox-devedition = pkgs.wrapFirefox pkgs.firefox-devedition-bin-unwrapped firefox-attrs;

	firefox = pkgs.writeShellScriptBin "firefox" ''
		${firefox-devedition}/bin/firefox -P default "$@"
	'' // {
		# satisfy home-manager
		inherit (pkgs) gtk3;
		inherit (firefox-attrs) applicationName extraNativeMessagingHosts;
		inherit (firefox-devedition) meta;
	};


in {
	# nixpkgs.overlays = [ (self: super: {
	# 	firefox-unwrapped = super.firefoxPackages.firefox.override {
	# 		crashreporterSupport = true;
	# 		pipewireSupport = true;
	# 		debugBuild = true;
	# 		drmSupport = true;
	# 	};
	# }) ];

	# Thanks, Firefox. Seriously.
	# See https://github.com/NixOS/nixpkgs/issues/47340#issuecomment-440645870.
	home.file = lib.flip lib.mapAttrs' nativeMessagingHosts (name: pkg: {
		name  = ".mozilla/native-messaging-hosts/${name}.json";
		value = {
			source = "${pkg}/lib/mozilla/native-messaging-hosts/${name}.json";
		};
	});

	programs.firefox.enable = true;
	programs.firefox.package = firefox;

	programs.firefox.profiles."Tunneled" = {
		id = 1;
		name = "Tunneled";
		path = "Tunneled";
		userContent = builtins.readFile ./userContent.css;
		userChrome  = ''
			${builtins.readFile ./userChrome.megabarstyler.css}
			${builtins.readFile ./userChrome.main.css}
		'';
	};

	programs.firefox.profiles."${profileName}" = {
		id = 0;
		name = profileName;
		path = profilePath;
		isDefault   = true;
		userContent = builtins.readFile ./userContent.css;
		userChrome  = ''
			${builtins.readFile ./userChrome.megabarstyler.css}
			${builtins.readFile ./userChrome.main.css}
		'';
		settings = {
			"xpinstall.signatures.required" = false;
			"dom.ipc.plugins.enabled" = false;
			"security.dialog_enable_delay" = 0;
			"dom.dialog_element.enabled" = true;
			"toolkit.legacyUserProfileCustomizations.stylesheets" = true;
			"layout.css.backdrop-filter.enabled" = true;
			"intl.accept_languages" = "en-us,en,vi";
			"findbar.highlightAll" = true;
			"font.language.group" = "ja";
			"font.minimum-size.x-western" = 9;
			"font.name.monospace.ja" = "monospace";
			"font.name.monospace.x-western" = "monospace";
			"dom.webgpu.enabled" = true;
			"gfx.webrender.all" = true;
			"gfx.webrender.compositor" = true;
			"media.ffmpeg.vaapi.enabled" = true;
			"devtools.styleeditor.autocompletion-enabled" = false;
			"devtools.theme" = "dark";
			"devtools.toolbox.host" = "right";
			"devtools.browsertoolbox.fission" = false;
			"browser.startup.homepage" = "about:blank";
			"browser.startup.page" = 3;
			"browser.tabs.drawInTitlebar" = true;
			"browser.display.use_system_colors" = true;
			"browser.download.autohideButton" = false;
			"browser.download.panel.shown" = true;
			"browser.aboutConfig.showWarning" = false;
			"browser.in-content.dark-mode" = true;
			"browser.menu.showViewImageInfo" = true;
		};
	};
}
