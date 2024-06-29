{ config, lib, pkgs, ... }:

{
	services.mullvad-vpn = {
		enable = true;
		enableExcludeWrapper = false;
		package = pkgs.mullvad-vpn;
	};

	networking.nftables.enable = true;
	networking.nftables.tables = lib.mkIf
		(config.services.mullvad-vpn.enable && config.services.tailscale.enable)
		{
			# Refer to https://mullvad.net/en/help/split-tunneling-with-linux-advanced.
			tailscale-mullvad-bypass = {
				family = "inet";
				content = ''
					chain excludeOutgoing {
						type route hook output priority 0;
						policy accept;
						ip daddr 100.64.0.0/10
							ct   mark set 0x00000f41
							meta mark set 0x6d6f6c65;
					}
				'';
			};
		};
}
