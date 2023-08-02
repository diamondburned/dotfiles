{ config, lib, pkgs, ... }:

# [Unit]
# Description=Disable Bluetooth before going to sleep
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
# ExecStart=/usr/bin/bluetoothctl power off
# ExecStop=/usr/bin/bluetoothctl power on
#
# [Install]
# WantedBy=sleep.target
# WantedBy=suspend.target
# WantedBy=hybrid-sleep.target
# WantedBy=suspend-then-hibernate.target

{
	systemd.services."bluetooth-disable-before-sleep" = {
		enable = true;
		description = "disable bluetooth for systemd sleep/suspend targets";
		before = [
			"sleep.target"
			"suspend.target"
			"hybrid-sleep.target"
			"suspend-then-hibernate.target"
		];
		unitConfig = {
			StopWhenUnneeded = true;
		};
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
			ExecStart = "${pkgs.bluez}/bin/bluetoothctl power off";
			ExecStop = "${pkgs.bluez}/bin/bluetoothctl power on";
		};
		wantedBy = [
			"sleep.target"
			"suspend.target"
			"hybrid-sleep.target"
			"suspend-then-hibernate.target"
		];
	};
}
