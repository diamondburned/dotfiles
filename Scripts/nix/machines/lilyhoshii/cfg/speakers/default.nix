{ config, lib, pkgs, ... }:

{
	imports = [
		<dotfiles/overlays/packages/speakersafetyd/module.nix>
	];

	# services.speakersafetyd = {
	# 	enable = true;
	# 	package = pkgs.speakersafetyd.overrideAttrs (old: {
	# 		postPatch = (old.postPatch or "") + ''
	# 			sed -i 's|" Speaker Volume"|" Speaker Playback Volume"|g' src/types.rs
	# 		'';
	# 	});
	# 	extraConfig = {
	# 		j313 = ./j313.conf;
	# 	};
	# };

	# Enable unsafe speaker configuration.
	# See sound/soc/apple/macaudio.c:71.
	boot.kernelParams = [ "snd-soc-macaudio.please_blow_up_my_speakers=1" ];
	boot.kernelPatches = [
		{
			name  = "enable-speakers";
			patch = ./AsahiLinux-enable-speakers.patch;
	 	}
	];

	nixpkgs.overlays = [
		(self: super: {
			alsa-ucm-conf-asahi = super.callPackage ./alsa-ucm-conf-asahi.nix {
				inherit (super) alsa-ucm-conf;
			};
			alsa-lib-asahi = super.alsa-lib.override {
				alsa-ucm-conf = self.alsa-ucm-conf-asahi;
			};
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
