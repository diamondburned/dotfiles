{ config, lib, pkgs, ...}:

{
	imports = [
		./tailscale.nix
		./mullvad.nix
	];

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
	};

	# networking.nameservers = [
	# 	# Cloudflare DNS with DNS-over-TLS.
	# 	"1.1.1.1#cloudflare-dns.com"
	# 	"1.0.0.1#cloudflare-dns.com"
	# 	# Google DNS with DNS-over-TLS.
	# 	"8.8.8.8#dns.google"
	# 	"8.8.4.4#dns.google"
	# 	# Tailscale DNS.
	# 	"100.100.100.100"
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
	};

	networking.nftables.enable = true;

	programs.openvpn3.enable = true;
}
