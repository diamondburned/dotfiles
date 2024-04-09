{ config, lib, pkgs, ... }:

let
	profileName = "default";
	profilePath = "q1f740f8.default";

	firefox = let
		pkg = pkgs.firefox-devedition;
	in
		pkg.override {
			cfg = {
				enableGnomeExtensions = true;
			};
		};

	makeFirefoxProfileDesktopFile = {
		profile,
		name ? "Firefox (${profile})",
		icon ? "firefox",
	}: pkgs.makeDesktopItem {
		name = "firefox-${profile}.desktop";
		# bin/find-desktop Firefox
		desktopName = name;
		genericName = "Web Browser (${name})";
		exec = "${firefox.meta.mainProgram} -p ${profile} %U";
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

	# nativeMessagingHosts = {
	# 	"org.gnome.shell.extensions.gsconnect" = pkgs.gnomeExtensions.gsconnect;
	# 	"org.gnome.chrome_gnome_shell"         = pkgs.chrome-gnome-shell;
	# };

	firefox-attrs = {
		applicationName = "firefox";
		forceWayland = true;
		# extraNativeMessagingHosts = lib.attrValues nativeMessagingHosts;
	};

in {
	home.packages = with pkgs; [
		(makeFirefoxProfileDesktopFile {
			profile = profileName;
			name = "Firefox (default)";
		})
		(makeFirefoxProfileDesktopFile {
			profile = "Tunneled";
		})
	];

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
			"media.av1.enabled" = false;
			"browser.sessionhistory.max_entries" = 15;
			"browser.send_pings" = false;
			"browser.cache.offline.enable" = true;
			"browser.cache.memory.capacity" = 14336;
			"browser.download.alwaysOpenPanel" = true;
			"xpinstall.signatures.required" = false;
			"dom.min_background_timeout_value" = 10000; # 10s
			"dom.timeout.throttling_delay" = 10000;     # 10s
			"dom.ipc.plugins.enabled" = false;
			"security.dialog_enable_delay" = 0;
			"dom.dialog_element.enabled" = true;
			"toolkit.legacyUserProfileCustomizations.stylesheets" = true;
			"layout.frame_rate" = 70;
			"layout.css.backdrop-filter.enabled" = true;
			"intl.accept_languages" = "en-us,en,vi";
			"findbar.highlightAll" = true;
			"font.language.group" = "ja";
			"font.minimum-size.x-western" = 9;
			"font.name.monospace.ja" = "monospace";
			"font.name.monospace.x-western" = "monospace";
			"font.name-list.emoji" = "emoji"; # why the fuck does Firefox have this
			"dom.webgpu.enabled" = true;
			"gfx.webrender.all" = true;
			"gfx.webrender.compositor" = true;
			"gfx.webrender.compositor.force-enabled" = false;
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
			"privacy.resistFingerprinting" = false; # breaks dark theme
			"privacy.antitracking.testing" = true;
			"privacy.trackingprotection.enabled" = true;
			"network.trr.mode" = 5;
			"widget.gtk.rounded-bottom-corners.enabled" = true;
		};
	};
}
