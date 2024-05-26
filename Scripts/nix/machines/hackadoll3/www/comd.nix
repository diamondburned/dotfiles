{ config, lib, pkgs, ... }:

let
	sources = import <dotfiles/nix/sources.nix> { inherit pkgs; };
	comd = (import sources.flake-compat { src = sources.comd; }).defaultNix;
in

{
	imports = [
		comd.overlays.default
	];

	services.comd = {
		enable = true;
		listenAddr = "127.0.0.1:28475";
		config = {
			base_path = "/api/commands";
			commands = {
				"volume_up" = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
				"volume_down" = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
			};
		};
	};

	diamond.tailnet-services.comd.caddyConfig = ''
		handle /api/commands* {
			reverse_proxy * localhost:28475
		}
	'';
}
