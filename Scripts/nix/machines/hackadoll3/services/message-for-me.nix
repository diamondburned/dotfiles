{ config, lib, pkgs, ... }:

let
	sources = import <dotfiles/nix/sources.nix> { };

	package = let
		flake = import sources.flake-compat {
			# src = sources.message-for-me;
			src = /home/diamond/Scripts/message-for-me;
		};
	in flake.defaultNix.packages.${pkgs.system}.default;

	runScript = pkgs.writeShellScript "message-for-me" ''
		token="$(${lib.getExe pkgs.libsecret} lookup service so.libdb.dissent.secrets)"
		export DISCORD_TOKEN="$token"
		exec ${lib.getExe package}
	'';
in

{
	home-manager.sharedModules = [
		{
			systemd.user.services.message-for-me = {
				Unit.Description = "message-for-me service daemon";
				Install.WantedBy = [ "default.target" ];
				Service.ExecStart = runScript;
			};
		}
	];
}
