{
	id = 0;
	name = "default";
	path = "q1f740f8.default";
	isDefault   = true;
	userChrome  = builtins.readFile ./userChrome.css;
	userContent = builtins.readFile ./userContent.css;
	settings = {
		"network.captive-portal-service.enabled" = false;
		"layout.css.backdrop-filter.enabled" = true;
		"intl.accept_languages" = "en-us,en,vi";
		"findbar.highlightAll" = true;
		"font.language.group" = "ja";
		"font.minimum-size.x-western" = 9;
		"font.name.monospace.ja" = "monospace";
		"font.name.monospace.x-western" = "monospace";
		"font.name.sans-serif.ja" = "sans-serif";
		"font.name.sans-serif.x-western" = "sans-serif";
		"font.name.serif.ja" = "serif";
		"font.name.serif.x-western" = "serif";
		"general.smoothScroll.mouseWheel.migrationPercent" = 0;
		"gfx.webrender.all" = true;
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
		"browser.uiCustomization.state" = builtins.toJSON ({
			"placements" = {
				"widget-overflow-fixed-list" = [];
				"nav-bar" = [
					"back-button"
					"forward-button"
					"stop-reload-button"
					"urlbar-container"
					"jid1-pn4afskf9wbada_jetpack-browser-action"
					"_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action"
					"addon_darkreader_org-browser-action"
					"ublock0_raymondhill_net-browser-action"
					"multipletab_piro_sakura_ne_jp-browser-action"
					"downloads-button"
					"fxa-toolbar-menu-button"
				];
				"toolbar-menubar" = [
					"menubar-items"
				];
				"TabsToolbar" = [
					"tabbrowser-tabs"
					"new-tab-button"
					"alltabs-button"
				];
				"PersonalToolbar" = [
					"personal-bookmarks"
					"managed-bookmarks"
				];
			};
			"seen" = [
				"developer-button"
				"jid1-pn4afskf9wbada_jetpack-browser-action"
				"_7a7a4a92-a2a0-41d1-9fd7-1e92480d612d_-browser-action"
				"addon_darkreader_org-browser-action"
				"ublock0_raymondhill_net-browser-action"
				"multipletab_piro_sakura_ne_jp-browser-action"
			];
			"dirtyAreaCache" = [
				"nav-bar"
				"toolbar-menubar"
				"TabsToolbar"
				"PersonalToolbar"
			];
			"currentVersion" = 16;
			"newElementCount" = 4;
		});
	};
}
