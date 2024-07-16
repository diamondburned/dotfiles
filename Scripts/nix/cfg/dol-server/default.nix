{ config, lib, pkgs, ... }@args:

{
	home-manager.sharedModules = [
		(import ./home.nix args)
	];

	diamond.tailnetServices.dol = {
		caddyConfig = ''
			# TODO: move this to a systemd service and use a reverse proxy to the
			# Unix socket.
			# reverse_proxy * localhost:19384
			reverse_proxy * unix//tmp/dol-server.sock
		'';
	};
}
