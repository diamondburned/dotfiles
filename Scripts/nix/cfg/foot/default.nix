{ config, lib, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		# foot
	];

	home-manager.sharedModules = [
		{
			imports = [ ./home.nix ];
		}
	];
}
