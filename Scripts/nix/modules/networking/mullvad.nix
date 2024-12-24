{ config, lib, pkgs, ... }:

{
	services.mullvad-vpn = {
		enable = true;
		enableExcludeWrapper = true;
		package = pkgs.mullvad-vpn;
	};

	networking.nftables.enable = true;
	networking.nftables.tables = lib.mkIf
		(config.services.mullvad-vpn.enable && config.services.tailscale.enable)
		{
			# Refer to:
			# https://mullvad.net/en/help/split-tunneling-with-linux-advanced
			# https://github.com/r3nor/mullvad-tailscale/blob/main/mullvad.rules
			tailscale-mullvad-bypass = {
				family = "inet";
				content = ''
					chain excludeOutgoing {
						type route hook output priority 0; policy accept;
						ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
					}

					chain allow-incoming {
						type filter hook input priority -100; policy accept;
						iifname "${config.services.tailscale.interfaceName}" ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
					}

					chain excludeDns {
						type filter hook output priority -10; policy accept;
						ip daddr 100.100.100.100 udp dport 53 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
						ip daddr 100.100.100.100 tcp dport 53 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
					}
				'';
			};
		};
}
