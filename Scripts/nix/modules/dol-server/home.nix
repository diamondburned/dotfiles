{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
	path' = /home/diamond/Scripts/dol-server;	
	exists = builtins.pathExists path';

	path = warnIf (!exists) "dol-server not found, skipping..." path';

	src = cleanSource path;

	package = pkgs.buildGoModule {
		name = "dol-server";
		inherit src;
		vendorHash = "sha256-1nn23qG2XBhkd8HcPXbheJ1SD5UovtiAUClGpPyCpTg=";
	};
in

{
	systemd.user.services.dol-server =
		if exists then
			{
				Unit = {
					Description = "Degrees of Lewdity server";
					PartOf = [ "default.target" ];
					After = [ "network.target" ];
				};
				Install = {
					WantedBy = [ "default.target" ];
				};
				Service = {
					ExecStart = pkgs.writeShellScript "dol-server-run" ''
						${package}/bin/dol-server \
							--config ${src}/dol-server.json \
							--listen-addr unix:///tmp/dol-server.sock
					'';
					Restart = "on-failure";
					RestartSec = "5s";
					UMask = "0000";
				};
			}
		else
			null;
}
