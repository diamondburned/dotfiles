{ config, lib, pkgs, ... }:

{
	home.packages = with pkgs; [
		gnome-usage
		gnome-sound-recorder
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
		gnomeExtensions.bluetooth-battery-meter
	];

	pam.sessionVariables = {
		NIXOS_OZONE_WL = "1";
		QT_QPA_PLATFORM = "wayland";
		MOZ_ENABLE_WAYLAND = "1";
	};

	systemd.user.sessionVariables = {
		NIXOS_OZONE_WL = "1";
		QT_QPA_PLATFORM = "wayland";
		MOZ_ENABLE_WAYLAND = "1";
	};

	dconf.settings = lib.attrsets.optionalAttrs
		(config.programs.foot.enable)
		{
			"org/gnome/desktop/default-applications/terminal" = {
				exec = "${pkgs.foot}/bin/foot";
				exec-arg = "-e";
			};
		};
}
