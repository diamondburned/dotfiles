{ config, lib, pkgs, ... }:

# This file is adapted from the official wiki page for Asahi Linux speakers:
# https://github.com/AsahiLinux/docs/wiki/SW:Speakers
#
# This file covers these items:
#
# - [x] Asahi Linux 6.5-25 (waiting on AsahiLinux/PKGBUILDs)
# - [x] alsa-ucm-conf-asahi
# - [x] asahi-audio
# - [x] speakersafetyd
# - [x] bankstown
# - [x] LSP plugins LV2 (how?)
# - [x] Pipewire v0.3.84
# - [x] Pipewire module-filter-chain-lv2
# - [x] Wireplumber v0.4.15
# - [x] Wireplumber w/ policy-dsp patch
#

{
	imports = [
		./speakersafetyd/module.nix
		./pipewire-0.3.84/module.nix # see disabledModules below
	];

	services.speakersafetyd = {
		enable = true;
		package = pkgs.callPackage ./speakersafetyd/package.nix { };
	};

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
			bankstown = pkgs.callPackage ./lsp-plugins/bankstown.nix { };

			lv2Plugins = with pkgs; [
				lsp-plugins
				bankstown
			];

			withPlugins = bin: pkg:
				pkg.overrideAttrs (old: {
					nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.makeWrapper ];
					postInstall = ''
						# Taken from pkgs/applications/audio/pulseeffects/default.nix.
						wrapProgram $out/bin/${bin} \
							--prefix LV2_PATH : ${lib.makeSearchPath "lib/lv2" lv2Plugins}
					'';
				});
		in
		{
			package =
				let
					pipewire = pkgs.callPackage ./pipewire-0.3.84/package.nix { };
				in
					assert lib.assertMsg
						(lib.versionAtLeast pipewire.version "0.3.84")
						("Pipewire version is too old, need at least 0.3.84, got ${pipewire.version}");
					pipewire;

			wireplumber.package =
				assert lib.assertMsg
					(lib.versionAtLeast pkgs.wireplumber.version "0.4.15")
					("Wireplumber version is too old, need at least 0.4.15, got ${pkgs.wireplumber.version}");
				withPlugins "wireplumber" (pkgs.wireplumber.overrideAttrs (old: {
					patches = [
						# policy-dsp: add ability to hide parent nodes 
						# https://gitlab.freedesktop.org/pipewire/wireplumber/-/merge_requests/558
						(builtins.fetchurl "https://gitlab.freedesktop.org/pipewire/wireplumber/-/merge_requests/558.patch")
					];
				}));
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
							source = "${asahi-audio}/share/${path}";
							target = "${path}";
							mode = "0444";
						};
					})
					paths);

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
