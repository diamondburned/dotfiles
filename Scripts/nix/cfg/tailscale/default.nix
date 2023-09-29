{ config, lib, pkgs, ... }:

{
	services.tailscale.enable = true;
	services.tailscale.useRoutingFeatures = "client";

	networking.firewall.interfaces.tailscale0 = {
		allowedTCPPortRanges = [ { from = 0; to = 65535; } ];
		allowedUDPPortRanges = [ { from = 0; to = 65535; } ];
	};
}
