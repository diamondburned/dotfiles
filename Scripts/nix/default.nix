let
	currentHostname =
		assert (lib.assertMsg (builtins.getEnv "HOSTNAME" != null) "hostname must be set");
		builtins.getEnv "HOSTNAME";
in

{
	hostname ? currentHostname,
}:

import <nixpkgs/nixos> {
	configuration = ./configuration.nix;
}
