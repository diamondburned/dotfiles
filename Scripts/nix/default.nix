{
	hostname ? builtins.getEnv "HOSTNAME",
	machine ? hostname,
	system ? builtins.currentSystem,
}:

import <nixpkgs/nixos> {
	configuration = {
		imports = [
			"${./.}/machines/base.nix"
			"${./.}/machines/${hostname}/configuration.nix"
		];
	};
	inherit system;
}
