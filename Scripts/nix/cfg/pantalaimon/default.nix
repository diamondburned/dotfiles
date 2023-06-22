{ config, lib, pkgs, ... }:

{
	services.pantalaimon = {
		enable = true;
		package = pkgs.nixpkgs_unstable_real.pantalaimon;
		settings = {
			Default = {
				LogLevel = "Debug";
				SSL = true;
				Notifications = "On";
			};
			local-matrix = {
				Homeserver = "https://matrix.org";
				ListenAddress = "localhost";
				ListenPort = 19375;
			};
		};
	};
}
