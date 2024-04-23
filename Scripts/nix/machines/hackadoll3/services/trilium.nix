{ config, lib, pkgs, ... }:

let
	port = 41875;
	dataDir = "/run/media/diamond/Secondary/Trilium";
in

{
	services.trilium-server = {
		inherit dataDir port;
		enable = true;
		host = "localhost";
		instanceName = config.networking.hostName;
		noAuthentication = true;
	};

	systemd.services.trilium-server.serviceConfig = with lib; {
		User = mkForce "diamond";
		Group = mkForce "trilium";
	};

	diamond.tailnet-services.trilium = {
		localPort = port;
	};
}
