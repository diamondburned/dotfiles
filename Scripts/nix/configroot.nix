{ config, lib, ... }:

{
	# Inject our config root. Use as nix.configRoot.
	options = {
		root = lib.mkOption {
			default  = builtins.toString ./.;
			readOnly = true;
		};
	};
}
