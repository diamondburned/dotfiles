{ config, lib, pkgs, ... }:

{
	boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
}
