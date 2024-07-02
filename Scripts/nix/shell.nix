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

	lib = pkgs.lib;

	nixPath = lib.concatStringsSep ":" [
		"/home/diamond/.nix-defexpr/channels"
		"/nix/var/nix/profiles/per-user/root/channels"
		"dotfiles=${builtins.toString ./.}"
		"nixos-config=${builtins.toString ./.}/configuration.nix"
	];
in

pkgs.mkShell {
	buildInputs = with pkgs; [
		# bonito
		niv
		git
		git-crypt
		gomod2nix
		nix-output-monitor
		lua-language-server

		(writeShellScriptBin "switch" ''
			export NIX_PATH=${lib.escapeShellArg nixPath}
			sudo bash -c 'nixos-rebuild --log-format internal-json -v switch |& nom --json'
		'')
	];

	shellHook = ''
		if [[ $HOSTNAME == "nixos" ]]; then
			echo "You probably want to manually set your \$HOSTNAME."
		else
			export HOSTNAME
		fi
		export NIX_PATH=${lib.escapeShellArg nixPath}
		export MACHINES="${builtins.concatStringsSep " " machines}"
	'';
}
