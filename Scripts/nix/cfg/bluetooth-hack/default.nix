{ config, lib, pkgs, ... }:

# https://unix.stackexchange.com/questions/539762/how-do-i-suspend-sleep-while-bluetooth-is-active
let bluetooth-sleep = pkgs.writeShellScript "bluetooth-sleep" (builtins.readFile ./bluetooth-sleep);
	id = {
		vendor = "8087";
		product = "0033";
	};
in

{
	systemd.services."bluetooth-sleep" = {
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
			ExecStart = with id; "${bluetooth-sleep} start ${vendor} ${product}";
			ExecStop = with id; "${bluetooth-sleep} stop ${vendor} ${product}";
		};
		wantedBy = [
			"sleep.target"
			"suspend.target"
			"hybrid-sleep.target"
			"suspend-then-hibernate.target"
		];
	};
}
