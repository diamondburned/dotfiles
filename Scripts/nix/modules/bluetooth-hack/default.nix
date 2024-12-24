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

let
	disconnectAll = pkgs.writeShellScript "disconnect-all-bluetooth" ''
		${pkgs.bluez}/bin/bluetoothctl devices Connected \
			| grep -o "[[:xdigit:]:]\{8,17\}" \
			| while read -r device; do bluetoothctl disconnect "$device"; done
	'';
in

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
			ExecStart = disconnectAll;
		};
		wantedBy = [
			"sleep.target"
			"suspend.target"
			"hybrid-sleep.target"
			"suspend-then-hibernate.target"
		];
	};
}
