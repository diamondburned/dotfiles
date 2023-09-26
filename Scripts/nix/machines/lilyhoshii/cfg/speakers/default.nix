{ config, lib, pkgs, ... }:

let
	alsa-ucm-conf-asahi = pkgs.callPackage ./alsa-ucm-conf-asahi.nix {
		inherit (pkgs) alsa-ucm-conf;
	};
in

{
	# Enable unsafe speaker configuration.
	# See sound/soc/apple/macaudio.c:71.
	boot.kernelParams = [ "snd-soc-macaudio.please_blow_up_my_speakers=1" ];
	boot.kernelPatches = [
		{
			name  = "enable-speakers";
			patch = ./AsahiLinux-enable-speakers.patch;
	 	}
	];

	environment.systemPackages = with pkgs; [
		alsa-ucm-conf-asahi
	];
}
