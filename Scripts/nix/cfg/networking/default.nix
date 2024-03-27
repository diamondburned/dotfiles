{ config, lib, pkgs, ...}:

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

	# Comment out all the DNS-over-TLS bits below.
	#
	# Tailscale already supports DNS-over-HTTPS on its own, and you can configure
	# your Tailscale account to skip the local DNS server and use only the DoH
	# ones.
	#
	# See https://github.com/tailscale/tailscale/issues/2056#issuecomment-883901641.

	services.resolved = {
		enable = true;
		# dnssec = "true";
		# dnsovertls = "true";

		# Is this needed?
		# fallbackDns = config.networking.nameservers;
	};

	# networking.search = [
	# 	# Add our Tailnet domain.
	# 	"~skate-gopher.ts.net"
	# 	"~ts.net"
	# ];
	#
	# networking.nameservers = [
	# 		# Cloudflare DNS with DNS-over-TLS.
	# 		"1.1.1.1#cloudflare-dns.com"
	# 		"1.0.0.1#cloudflare-dns.com"
	# 		# Google DNS with DNS-over-TLS.
	# 		"8.8.8.8#dns.google"
	# 		"8.8.4.4#dns.google"
	# 		# Tailscale DNS.
	# 		"100.100.100.100%tailscale0"
	# 		"100.100.100.100%tailscale0#skate-gopher.ts.net"
	# ];

	networking.networkmanager = {
		enable = true;
		dns = "systemd-resolved";
	};

	networking.firewall = {
		enable = true;
		#                   v  Steam  v
		allowedTCPPorts = [ 27036 27037 ];
		allowedUDPPorts = [ 27031 27036 ];
		# Allow any ports for Tailscale.
		interfaces.tailscale0 = {
			allowedTCPPortRanges = [ { from = 0; to = 65535; } ];
			allowedUDPPortRanges = [ { from = 0; to = 65535; } ];
		};
	};
}
