{ config, lib, pkgs, ... }:

let
	port = 41875;
in

{
	services.trilium-server = {
		enable = true;
		host = "localhost";
		port = port;
		dataDir = "/home/trilium";
		instanceName = config.networking.hostName;
		noAuthentication = true;
	};

	# services.outline = {
	# 	enable = true;
	# 	forceHttps = false;
	# 	port = port;
	# 	publicUrl = "http://outline";
	# 	storage = {
	# 		storageType = "local";
	# 		localRootDir = "/home/outline";
	# 	};
	# };

	users.users.trilium = {
		homeMode = "750";
		createHome = true;
	};

	users.users.diamond.extraGroups = [ "trilium" ];

	diamond.tailnetServices.trilium = {
		localPort = port;
	};
}
