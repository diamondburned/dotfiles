{ pkgs, config, lib, ... }:

{
	environment.etc."keyd/air60.conf".source = ./keyd.ini;

	systemd.services.keyd = {
		enable = true;
		description = "key remapping daemon";
		after = [ "local-fs.target" ];
		requires = [ "local-fs.target" ];
		wantedBy = [ "sysinit.target" ];
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.keyd}/bin/keyd";
		};
	};
}
