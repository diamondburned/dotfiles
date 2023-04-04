{ config, lib, pkgs, ... }:

{
	services.avahi = {
		enable = false;
		nssmdns = true;
		publish = {
			enable = true;
			domain = true;
			addresses = true;
			workstation = true;
			userServices = true;
		};
	};

	# Enable mDNS subdomain for local network.
	# https://askubuntu.com/questions/1175380/avahi-name-resolution-not-respected-for-subdomains-in-19-04
	# system.nssDatabases.hosts = lib.mkBefore [ "mdns" ];
	# environment.etc."mdns.allow".text = lib.concatStringsSep "\n" [
	# 	".local"
	# 	".local."
	# ];
}
