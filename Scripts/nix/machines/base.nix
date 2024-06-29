{ config, lib, pkgs, ... }:

let
	rootDir = ./..;
in

{
	home-manager.users.diamond = {
		imports = [
			# Automatically push dotfiles.
			(import <dotfiles/utils/schedule.nix> {
				name        = "dotfiles-pusher";
				description = "Automatically push dotfiles";
				calendar    = "hourly";
				command     = ''
					cd ~/ && git add -A && git commit -m Update && git pull --rebase && git push origin
					exit 0
				'';
			})
		];
	};

	environment.sessionVariables = {
		HOSTNAME = config.networking.hostName;
	};

	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	nix.nixPath = [
		"dotfiles=${rootDir}"
		"nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
		"nixos-config=${rootDir}/configuration.nix"
		"/nix/var/nix/profiles/per-user/root/channels"
	];

	# Inject our config root. Use as nix.configRoot.
	# options = {
	# 	root = lib.mkOption {
	# 		default  = builtins.toString ./.;
	# 		readOnly = true;
	# 	};
	# };

	# Disable split lock detection since it penalizes the performance of certain
	# apps for arbitrary reasons.
	boot.kernelParams = [ "split_lock_detect=off" ];

	users.users.diamond.openssh.authorizedKeys.keyFiles = [
		"${rootDir}/public_keys"
	];

	services.xserver.gdk-pixbuf.modulePackages = with pkgs; [
		librsvg
		webp-pixbuf-loader
	];

}
