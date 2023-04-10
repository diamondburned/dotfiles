{ config, lib, pkgs, ... }:

# [Unit]
# Description=disable bluetooth for systemd sleep/suspend targets
# Before=sleep.target
# Before=suspend.target
# Before=hybrid-sleep.target
# Before=suspend-then-hibernate.target
# StopWhenUnneeded=yes
# 
# [Service]
# Type=oneshot
# RemainAfterExit=yes
# 
# ExecStart=/usr/bin/rfkill block bluetooth
# ExecStop=/usr/bin/rfkill unblock bluetooth
# 
# [Install]
# WantedBy=sleep.target
# WantedBy=suspend.target
# WantedBy=hybrid-sleep.target
# WantedBy=suspend-then-hibernate.target

{
	systemd.services."bluetooth-sleep" = {
		enable = true;
		description = "disable bluetooth for systemd sleep/suspend targets";
		before = [ "sleep.target" "suspend.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
		unitConfig.Type = "oneshot";
		unitConfig.StopWhenUnneeded = true;
		serviceConfig.RemainAfterExit = true;
		serviceConfig.ExecStart = "${pkgs.util-linux}/bin/rfkill block bluetooth";
		serviceConfig.ExecStop = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
		wantedBy = [ "sleep.target" "suspend.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
	};
}
