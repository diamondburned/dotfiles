{ config, lib, pkgs, ... }:

let
	hostname =
		assert (lib.assertMsg (builtins.getEnv "HOSTNAME" != null) "hostname must be set");
		builtins.getEnv "HOSTNAME";

	configuration =
		"${builtins.toPath ./.}/machines/${hostname}/configuration.nix";
in

{
	imports = [ "${configuration}"];

	home-manager.users.diamond = {
		imports = [
			# Automatically push dotfiles.
			(import <dotfiles/utils/schedule.nix> {
				name        = "dotfiles-pusher";
				description = "Automatically push dotfiles";
				calendar    = "hourly";
				command     = ''
					cd ~/ && git add -A && git commit -m Update && git push origin
					exit 0
				'';
			})
		];
	};

	environment.sessionVariables = {
		HOSTNAME = config.networking.hostName;
	};

	nix.nixPath = [
		"dotfiles=${builtins.toString ./.}"
		"nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
		"nixos-config=${builtins.toString ./.}/configuration.nix"
		"/nix/var/nix/profiles/per-user/root/channels"
	];

	# Inject our config root. Use as nix.configRoot.
	# options = {
	# 	root = lib.mkOption {
	# 		default  = builtins.toString ./.;
	# 		readOnly = true;
	# 	};
	# };
}
