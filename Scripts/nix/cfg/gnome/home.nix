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

	pam.sessionVariables = {
		NIXOS_OZONE_WL = "1";
		QT_QPA_PLATFORM = "wayland";
		MOZ_ENABLE_WAYLAND = "1";
	};
}
