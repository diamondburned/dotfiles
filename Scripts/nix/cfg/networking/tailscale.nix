{ config, lib, pkgs, ... }:

{
	services.tailscale = {
		enable = true;
		extraUpFlags = [
			"--ssh"
			"--accept-dns"
			"--advertise-exit-node"
			"--operator=diamond"
		];
		useRoutingFeatures = "client";
	};

	home-manager.sharedModules = [
		{
			systemd.user.services.taildrop-loop = {
				Unit.Description = "Automatically fetch Taildropped files to Downloads";
				Install.WantedBy = ["graphical-session.target"];
				Service = {
					ExecStart = "${lib.getExe pkgs.tailscale} file get --loop %h/Downloads";
					Restart = "always";
					RestartSec = "5";
				};
			};
		}
	];
}
