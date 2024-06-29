{ config, lib, pkgs, ... }:

{
	services.mullvad-vpn = {
		enable = true;
		package = pkgs.mullvad-vpn;
	};

	# Hijack the Tailscale service to add an exception into Mullvad.
	systemd.services.tailscaled = {

	};
}
