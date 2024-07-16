{ config, lib, pkgs, ... }:

let
	hostname = config.networking.hostName;
in

{
	# Enable netdata, which is a lightweight alternative to Grafana.
	# https://nixos.wiki/wiki/Netdata
	# https://dataswamp.org/~solene/2022-09-16-netdata-cloud-nixos.html
	services.netdata = {
		enable = true;
		config =
			with lib;
			with builtins;
			let
				concat = l: concatStringsSep " " (flatten l);
				config = {
					web = rec {
						"web server threads" = 6;
						"default port" = 19999;
						"bind to" = concat [ "127.0.0.1" ];
					};
				};
			in config;
		configDir = {
			"stream.conf" = pkgs.writeText "stream.conf" ''
				[stream]
					enabled = yes
					enable compression = yes

				[426eae98-5238-4203-ac5c-8553311fd92e]
					enabled = yes
					allow from = 100.*
					default memory mode = dbengine
					health enabled by default = yes
			'';
		};
	};

	diamond.tailnetServices."${hostname}-netdata".localPort = 19999;
	diamond.localhostConfig = ''
		handle /netdata {
			redir * ${hostname}:19999
		}
	'';
}
