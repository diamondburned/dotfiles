{ config, lib, pkgs, ... }:

{
	services.trilium-server = {
		enable = true;
		dataDir = "/run/media/diamond/Secondary/Trilium";
		host = "localhost";
		port = 41875;
		instanceName = config.networking.hostName;
		noAuthentication = true;
	};
}
