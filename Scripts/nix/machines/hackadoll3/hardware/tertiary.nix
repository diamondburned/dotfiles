{ config, lib, pkgs, ... }:

{
	fileSystems."/run/media/diamond/Tertiary" = {
		device = "/dev/disk/by-uuid/3479fa6a-2c35-4341-a787-28103626fa21";
		fsType = "auto";
		options = [
			"nodev"
			"nosuid"
			"nofail"
			"noatime"
			"autodefrag"
			"x-gvfs-show"
			"x-gvfs-name=Tertiary"
		];
	};
}
