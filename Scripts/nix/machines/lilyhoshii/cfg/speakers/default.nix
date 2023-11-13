{ config, lib, pkgs, ... }:

# This file is adapted from the official wiki page for Asahi Linux speakers:
# https://github.com/AsahiLinux/docs/wiki/SW:Speakers
#
# This file covers these items:
#
# - [x] alsa-ucm-conf-asahi
# - [ ] asahi-audio
# - [x] speakersafetyd
# - [ ] bankstown
# - [ ] LSP plugins LV2 (how?)
# - [.] Pipewire v0.3.84 (nixpkgs-dependent)
# - [.] Pipewire module-filter-chain-lv2
# - [.] Wireplumber v0.4.15
# - [x] Wireplumber w/ policy-dsp patch
#

{
	imports = [
		./speakersafetyd/module.nix
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
		})
	];

	services.pipewire =
		let
			unstable = import <unstable> { };
		in
			{
				package =
					# assert lib.assertMsg
					# 	(lib.versionAtLeast unstable.pipewire.version "0.3.84")
					# 	("Pipewire version is too old, need at least 0.3.84, got ${unstable.pipewire.version}");
					unstable.pipewire;

				wireplumber.package =
					# assert lib.assertMsg
					# 	(lib.versionAtLeast unstable.wireplumber.version "0.4.15")
					# 	("Wireplumber version is too old, need at least 0.4.15, got ${unstable.wireplumber.version}");
					unstable.wireplumber.overrideAttrs (old: {
						patches = [
							# policy-dsp: add ability to hide parent nodes 
							# https://gitlab.freedesktop.org/pipewire/wireplumber/-/merge_requests/558
							(builtins.fetchurl "https://gitlab.freedesktop.org/pipewire/wireplumber/-/merge_requests/558.patch")
						];
					});
			};

	# aaaaa
	# https://github.com/NixOS/nixpkgs/issues/200744
	# and
	#  ${asahi-audio}/share/asahi-audio
	#  ├── pipewire
	#  │   ├── pipewire.conf.d
	#  │   │   └── 99-asahi.conf
	#  │   └── pipewire-pulse.conf.d
	#  │       └── 99-asahi.conf
	#  └── wireplumber
	#      ├── main.lua.d
	#      │   └── 85-asahi.lua
	#      ├── policy.lua.d
	#      │   └── 85-asahi-policy.lua
	#      └── scripts
	#          └── policy-asahi.lua
	environment.etc =
		with lib;
		with builtins;
		let
			asahi-audio = pkgs.callPackage ./asahi-audio.nix { };
			paths = [
				"pipewire/pipewire.conf.d/99-asahi.conf"
				"pipewire/pipewire-pulse.conf.d/99-asahi.conf"
				"wireplumber/main.lua.d/85-asahi.lua"
				"wireplumber/policy.lua.d/85-asahi-policy.lua"
				"wireplumber/scripts/policy-asahi.lua"
			];
		in
			listToAttrs
				(map
					(path: {
						name = "${path}";
						value = {
							source = "${asahi-audio}/share/asahi-audio/${path}";
							mode = "0444";
						};
					})
					paths);

	# The ALSA config doesn't seem to work at all, but it at least detects the speakers. The speakers
	# are still detected even without this.

	system.replaceRuntimeDependencies = [
		{
			original = pkgs.alsa-ucm-conf;
			replacement = pkgs.alsa-ucm-conf-asahi;
		}
		{
			original = pkgs.alsa-lib;
			replacement = pkgs.alsa-lib-asahi;
		}
	];
}
