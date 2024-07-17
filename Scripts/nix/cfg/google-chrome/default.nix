{ config, lib, pkgs, ... }:

{
	home-manager.sharedModules = [
		{
			imports = [ ./home.nix ];
		}
	];
}
