{ lib, pkgs, config, ... }:

let utils = import ./utils.nix lib;

	eq = name: import "${./EQ}/${name}.nix";
	eqs = {
		"I'm Fulla Schiit + HIFIMAN HE400i rtings EQ" = {
			graph  = eq "HIFIMAN HE400i rtings";
			target = "alsa_output.usb-Schiit_Audio_I_m_Fulla_Schiit-00.analog-stereo";
			audio = {
				# cat /proc/asound/Schiit/stream0
				rate   = 48000;
				format = "S24_3LE";
				allowedRates = [ 44100 48000 88200 96000 176400 192000 352800 384000 ];
				periodSize   = 128;
			};
			args = {
				"audio.position" = [ "FL" "FR" ];
				"playback.props" = {
					"audio.position" = [ "FL" "FR" ]; # check Carla
				};
			};
		};
	};

in {
	sound.enable = true;
	hardware.pulseaudio.enable = lib.mkForce false;

	services.pipewire = {
		enable = true;
		package = pkgs.nixpkgs_unstable.pipewire.overrideAttrs(old: {
			version = "0.3.52-0c8cd4a";
			src = pkgs.fetchFromGitLab {
				domain = "gitlab.freedesktop.org";
				owner  = "pipewire";
				repo   = "pipewire";
				rev    = "0c8cd4ab52557681df70e24df9072e2df7c7d6ff";
				sha256 = "1gjhpbsswyywffvc84hq1vmzxfk80prh0c5v6v0ag77cnkz0q5yc";
			};
			mesonFlags = old.mesonFlags ++ [ "-Dbluez5-codec-lc3plus=disabled" ];
		});

		alsa.enable = true;
		alsa.support32Bit = true;
		jack.enable = true;
		pulse.enable = true;

		config.pipewire = {
			"context.properties" = {
				"default.clock.rate" = 48000;
				"default.clock.quantum" = 4096;
				"default.clock.min-quantum" = 64;
				"default.clock.max-quantum" = 10240;
			};
			"context.modules" = [
				{
					name = "libpipewire-module-rtkit";
					args = {};
					flags = [ "ifexists" "nofail" ];
				}
				{ name = "libpipewire-module-protocol-native"; }
				{ name = "libpipewire-module-profiler"; }
				{ name = "libpipewire-module-metadata"; }
				{ name = "libpipewire-module-spa-device-factory"; }
				{ name = "libpipewire-module-spa-node-factory"; }
				{ name = "libpipewire-module-client-node"; }
				{ name = "libpipewire-module-client-device"; }
				{
					name = "libpipewire-module-portal";
					flags = [ "ifexists" "nofail" ];
				}
				{
					name = "libpipewire-module-access";
					args = {};
				}
				{ name = "libpipewire-module-adapter"; }
				{ name = "libpipewire-module-link-factory"; }
				{ name = "libpipewire-module-session-manager"; }
			] ++ (utils.filterChains eqs);
		};

		# https://nixos.wiki/wiki/PipeWire
		media-session.config = {
			alsa-monitor.rules = utils.alsaMonitorRules eqs;
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
