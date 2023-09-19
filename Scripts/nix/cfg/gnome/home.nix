{ config, lib, pkgs, ... }:

{
	home.packages = with pkgs; [
			gnome-usage
			gnome.polari
			gnomeExtensions.vitals
			gnomeExtensions.caffeine
			gnomeExtensions.worksets
			gnomeExtensions.gsconnect
			gnomeExtensions.dash-to-panel
			gnomeExtensions.tiling-assistant
			gnomeExtensions.brightness-control-using-ddcutil
			gnomeExtensions.search-light
			gnomeExtensions.rounded-window-corners
			gnomeExtensions.expandable-notifications
			gnomeExtensions.notification-banner-reloaded
	];
}
