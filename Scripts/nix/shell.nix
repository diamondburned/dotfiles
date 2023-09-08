{ pkgs ? import <nixpkgs> {} }:

let
	machines =
		with pkgs.lib;
		mapAttrsToList
			(name: type: removeSuffix ".toml" name)
			(filterAttrs
				(name: type: hasSuffix ".toml" name)
				(builtins.readDir ./.));
in

pkgs.mkShell {
	buildInputs = with pkgs; [
		# bonito
		git
		git-crypt
	];
	shellHook = ''
		export HOSTNAME
	'';
	NIX_PATH = builtins.concatStringsSep ":" [
		"dotfiles=${builtins.toString ./.}"
		"nixos-config=/etc/nixos/configuration.nix"
		"/nix/var/nix/profiles/per-user/root/channels"
	];
	MACHINES = builtins.concatStringsSep " " machines;
}
