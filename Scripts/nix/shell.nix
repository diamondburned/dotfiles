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
		niv
		git
		git-crypt
		gomod2nix
		nix-output-monitor
		lua-language-server
	];
	shellHook = ''
		if [[ $HOSTNAME == "nixos" ]]; then
			echo "You probably want to manually set your \$HOSTNAME."
		else
			export HOSTNAME
		fi
		export NIX_PATH="$NIX_PATH:dotfiles=${builtins.toString ./.}"
		export MACHINES="${builtins.concatStringsSep " " machines}"
	'';
}
