{ config, lib, pkgs, ... }:

let
	bulbremote = pkgs.fetchzip {
		url = "https://github.com/diamondburned/bulbremote/releases/download/v0.0.3/dist.tar.gz";
		sha256 = "sha256-V4DbvuiKDi6fUhVp74AQJll/AWY+SRCkMALDNjG/7ZE=";
	};

	secrets = import ./secrets/bulbremote.nix;

	configJSON = builtins.toJSON {
		JSONBIN_ID = secrets.jsonbinID;
		JSONBIN_TOKEN = secrets.jsonbinToken;
	};
in

{
	diamond.tailnetServices.bulb = ''
		handle * {
			root * ${bulbremote}
			file_server
		}
		handle /api/config {
			respond `${configJSON}`
		}
		handle /api/command {
			method * GET
			rewrite * /cm?cmnd={query.cmnd}
			reverse_proxy * ${secrets.tasmotaAddress}
		}
	'';
}
