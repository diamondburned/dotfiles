{ lib, pkgs, config, ... }:

let utils = import ./utils.nix lib;

	eq = name: import "${./EQ}/${name}.nix";
	eqs = {
		"HIFIMAN HE400i EQ (rtings)" = {
			short  = "he400i-rtings";
			graph  = eq "HIFIMAN HE400i rtings";
			target = "alsa_output.usb-Schiit_Audio_I_m_Fulla_Schiit-00.analog-stereo";
			audio = {
				# cat /proc/asound/Schiit/stream0
				rate   = 48000;
				format = "S24_3LE";
				allowedRates = [ 44100 48000 88200 96000 176400 192000 ];
				# periodSize   = 128;
			};
			args = {
				"audio.channels" = 2;
				"audio.position" = [ "FL" "FR" ];
				"playback.props" = {
					"audio.position" = [ "FL" "FR" ]; # check Carla
				};
			};
		};
	};

	nixpkgs_pipewire_0_3_57 = import (pkgs.fetchFromGitHub {
		owner  = "NixOS";
		repo   = "nixpkgs";
		rev    = "48bf1dd780a71096ef93ed2373e087ec6cba1351";
		sha256 = "1jb62j2mqww93zl7qka6p5zxfyg42nzzzpi6sb6vazphszhshbgp";
	}) {};

in {
	sound.enable = true;
	hardware.pulseaudio.enable = lib.mkForce false;

	services.pipewire = {
		enable = true;
		# GNOME Shell's new regression workaround requires a specific minimum
		# Pipewire version. This will cause a fuckton of things in our system
		# to be rebuilt, but until this is fixed, we have no choice.
		#
		# For more information, see the commit
		# https://gitlab.gnome.org/GNOME/gnome-shell/-/commit/d32c0348.
		package = pkgs.nixpkgs_unstable_real.pipewire;

		alsa.enable = false;
		alsa.support32Bit = false;
		jack.enable = true;
		pulse.enable = true;

		config.pipewire = {
			"context.properties" = {
				"default.clock.rate" = 48000;
				"default.clock.quantum" = 4096;
				"default.clock.min-quantum" = 64;
				"default.clock.max-quantum" = 10240;
			};
		};

		# https://nixos.wiki/wiki/PipeWire
		media-session.config = {
			bluez-monitor.rules = [
				{
					# Match all.
					matches = [ { "device.name" = "~bluez_card.*"; } ];
					actions = {
						"update-props" = {
							"bluez5.reconnect-profiles" = [ "a2dp_sink" "hfp_hf" "hsp_hs" ];
							"bluez5.msbc-support" = true;
							"bluez5.sbc-xq-support" = true;
						};
					};
				}
			];
		};
	};
}
