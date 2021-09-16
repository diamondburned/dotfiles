{ name, description, calendar, command }:

{ pkgs, lib, config, ... }:

{
	systemd.user.timers."${name}" = {
		Unit = {
			Description = description;
		};
		Install = {
			WantedBy = [ "timers.target" ];
		};
		Timer = {
			OnCalendar = calendar;
			Unit = "${name}.service";
		};
	};

	systemd.user.services."${name}" = {
		Unit = {
			Description = description;
		};
		Service = {
			Type = "oneshot";
			ExecStart = "${pkgs.writeShellScript "${name}.sh" command}";
		};
	};
}
