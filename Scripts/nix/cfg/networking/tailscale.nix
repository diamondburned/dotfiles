{ config, lib, pkgs, ... }:

let
	tailscaleInterface = "tailscale0";
in

{
	services.tailscale = {
		enable = true;
		extraUpFlags = [
			"--accept-dns"
			"--advertise-exit-node"
			"--operator=diamond"
		];
		openFirewall = true;
		interfaceName = tailscaleInterface;
		useRoutingFeatures = "both";
	};

	networking.firewall = {
		# Allow any ports for Tailscale.
		interfaces.${tailscaleInterface} = {
			allowedTCPPortRanges = [ { from = 0; to = 65535; } ];
			allowedUDPPortRanges = [ { from = 0; to = 65535; } ];
		};
		# Allow any traffic to the Tailscale interface.
		# I think?
		trustedInterfaces = [
			tailscaleInterface
		];
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
