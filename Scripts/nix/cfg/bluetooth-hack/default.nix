{ config, lib, pkgs, ... }:

{
	systemd.services."bluetooth-sleep" = {
		enable = true;
		description = "disable bluetooth for systemd sleep/suspend targets";
		before = [ "sleep.target" "suspend.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
		stopWhenUnneeded = true;
		type = "oneshot";
		remainAfterExit = true;
		serviceConfig.ExecStart = "${pkgs.rfkill}/bin/rfkill block bluetooth";
		serviceConfig.ExecStop = "${pkgs.rfkill}/bin/rfkill unblock bluetooth";
		wantedBy = [ "sleep.target" "suspend.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
	};
}
