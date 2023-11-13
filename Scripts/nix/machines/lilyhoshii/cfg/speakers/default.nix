{ config, lib, pkgs, ... }:

# This file is adapted from the official wiki page for Asahi Linux speakers:
# https://github.com/AsahiLinux/docs/wiki/SW:Speakers

{
	imports = [
		<dotfiles/overlays/packages/speakersafetyd/module.nix>
	];

	# Enable unsafe speaker configuration.
	# See sound/soc/apple/macaudio.c:71.
	boot.kernelParams = [ "snd-soc-macaudio.please_blow_up_my_speakers=1" ];
	boot.kernelPatches = [
		{
			name  = "enable-speakers";
			patch = ./AsahiLinux-enable-speakers.patch;
	 	}
	];

	services.speakersafetyd.enable = true;

	nixpkgs.overlays = [
		(self: super: {
			alsa-ucm-conf-asahi = super.callPackage ./alsa-ucm-conf-asahi.nix {
				inherit (super) alsa-ucm-conf;
			};
			alsa-lib-asahi = super.alsa-lib.override {
				alsa-ucm-conf = self.alsa-ucm-conf-asahi;
			};
			wireplumber = super.wireplumber.overrideAttrs (old: {
				patches = [
					# policy-dsp: add ability to hide parent nodes 
					# https://gitlab.freedesktop.org/pipewire/wireplumber/-/merge_requests/558
					(builtins.fetchurl "https://gitlab.freedesktop.org/pipewire/wireplumber/-/merge_requests/558.patch")
				];
			});
		})
	];

	# The ALSA config doesn't seem to work at all, but it at least detects the speakers. The speakers
	# are still detected even without this.

	# system.replaceRuntimeDependencies = [
	# 	{
	# 		original = pkgs.alsa-ucm-conf;
	# 		replacement = pkgs.alsa-ucm-conf-asahi;
	# 	}
	# 	{
	# 		original = pkgs.alsa-lib;
	# 		replacement = pkgs.alsa-lib-asahi;
	# 	}
	# ];

	# environment.systemPackages = with pkgs; [
	# 	alsa-ucm-conf-asahi
	# ];
}
