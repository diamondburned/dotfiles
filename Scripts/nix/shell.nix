{
	pkgs ? import <nixpkgs> {
		overlays = [
			(import ./overlays/gomod2nix.nix)
		];
	}
}:

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
		gomod2nix
		nix-output-monitor
	];
	shellHook = ''
		if [[ $HOSTNAME == "nixos" ]]; then
			echo "You probably want to manually set your \$HOSTNAME."
		else
			export HOSTNAME
		fi
	'';
	NIX_PATH = builtins.concatStringsSep ":" [
		"dotfiles=${builtins.toString ./.}"
		"nixos-config=/etc/nixos/configuration.nix"
		"/nix/var/nix/profiles/per-user/root/channels"
	];
	MACHINES = builtins.concatStringsSep " " machines;
}
