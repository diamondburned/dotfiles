{ config, lib, pkgs, ... }:

let
	hostname =
		assert (lib.assertMsg (builtins.getEnv "HOSTNAME" != null) "hostname must be set");
		builtins.getEnv "HOSTNAME";
in

{
	imports = [
		"${./.}/machines/base.nix"
		"${./.}/machines/${hostname}/configuration.nix"
	];
}
