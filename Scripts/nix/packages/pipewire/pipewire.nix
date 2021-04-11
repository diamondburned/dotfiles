{ config, lib, pkgs, ... }:

with lib;
let
	pipewireSrc = pkgs.fetchFromGitHub {
		repo	= "pipewire";
		owner = "pipewire";
		rev	 = "0.3.21";
		sha256 = "1r3yj1l0bqdyigzv15ajjyv20gj8fxgdrnnqg08888hg6cyp70nr";
	};

	jack-libs = pkgs.runCommand "jack-libs" {} ''
		mkdir -p "$out/lib"
		ln -s "${pkgs.pipewire.jack}/lib" "$out/lib/pipewire"
	'';

in
{
	nixpkgs.overlays = [(self: super: {
		pipewire = (super.pipewire.override { hsphfpdSupport = true; }).overrideAttrs
			({ ... }: {
				version = "0.3.21";
				src = pipewireSrc;
				patches = [
					(pkgs.path + "/pkgs/development/libraries/pipewire/alsa-profiles-use-libdir.patch")
					(pkgs.path + "/pkgs/development/libraries/pipewire/installed-tests-path.patch")
					(pkgs.path + "/pkgs/development/libraries/pipewire/pipewire-config-dir.patch")
					./pipewire-pulse-path.patch
				];
			});
		pipewirei686 = (super.pkgsi686Linux.pipewire.override { hsphfpdSupport = true; }).overrideAttrs
			({ ... }: {
				version = "0.3.21";
				src = pipewireSrc;
				patches = [
					(pkgs.path + "/pkgs/development/libraries/pipewire/alsa-profiles-use-libdir.patch")
					(pkgs.path + "/pkgs/development/libraries/pipewire/installed-tests-path.patch")
					(pkgs.path + "/pkgs/development/libraries/pipewire/pipewire-config-dir.patch")
					./pipewire-pulse-path.patch
				];
			});
	})];

	environment.systemPackages = with pkgs; [ pipewire pulseaudio pavucontrol alsaUtils jack-libs ];
	systemd.packages = with pkgs; [ pipewire pipewire.pulse ];
	services.udev.packages = with pkgs; [ pipewire ];
	systemd.user.sockets.pipewire.wantedBy = [ "sockets.target" ];
	systemd.user.sockets.pipewire-pulse.wantedBy = [ "sockets.target" ];
	systemd.user.services.pipewire.bindsTo = [ "dbus.service" ];
	environment.sessionVariables.LD_LIBRARY_PATH = lib.mkForce "/run/current-system/sw/lib/pipewire";
	environment.etc."alsa/conf.d/50-pipewire.conf".source =
		"${pkgs.pipewire}/share/alsa/alsa.conf.d/50-pipewire.conf";
	environment.etc."alsa/conf.d/99-pipewire-default.conf".source =
		"${pkgs.pipewire}/share/alsa/alsa.conf.d/99-pipewire-default.conf";
	environment.etc."pipewire/pipewire.conf".text = ''
		properties = {
			log.level = 4
			library.name.system = support/libspa-support
			context.data-loop.library.name.system = support/libspa-support
			default.clock.rate = 48000
		}
		spa-libs = {
			audio.convert* = audioconvert/libspa-audioconvert
			api.alsa.* = alsa/libspa-alsa
			api.v4l2.* = v4l2/libspa-v4l2
			api.libcamera.* = libcamera/libspa-libcamera
			api.bluez5.* = bluez5/libspa-bluez5
			api.vulkan.* = vulkan/libspa-vulkan
			api.jack.* = jack/libspa-jack
			support.* = support/libspa-support
		}
		modules = {
			libpipewire-module-rtkit = {
				"#args" = {
					nice.level = -11
					rt.prio = 20
					rt.time.soft = 200000
					rt.time.hard = 200000
				}
				"flags" = "ifexists|nofail"
			}
			libpipewire-module-protocol-native = {}
			libpipewire-module-profiler = {}
			libpipewire-module-metadata = {}
			libpipewire-module-spa-device-factory = {}
			libpipewire-module-spa-node-factory = {}
			libpipewire-module-client-node = {}
			libpipewire-module-client-device = {}
			libpipewire-module-portal = {}
			libpipewire-module-access = {
				"#args" = {
					access.allowed = ${pkgs.pipewire}/bin/pipewire-media-session
					access.force = flatpak
				}
			}
			libpipewire-module-adapter = {}
			libpipewire-module-link-factory = {}
			libpipewire-module-session-manager = {}
		}
		objects = {}
		exec = {
			"${pkgs.pipewire}/bin/pipewire-media-session" = {}
		}
	'';
	environment.etc."alsa/conf.d/49-pipewire-modules.conf".text = ''
		pcm_type.pipewire {
			libs {
				native ${pkgs.pipewire.lib}/lib/alsa-lib/libasound_module_pcm_pipewire.so
				32Bit ${pkgs.pipewirei686.lib}/lib/alsa-lib/libasound_module_pcm_pipewire.so
			}
		}
		ctl_type.pipewire {
			libs {
				native ${pkgs.pipewire.lib}/lib/alsa-lib/libasound_module_ctl_pipewire.so
				32Bit ${pkgs.pipewirei686.lib}/lib/alsa-lib/libasound_module_ctl_pipewire.so
			}
		}
	'';
	environment.etc."pipewire/media-session.d/alsa-monitor.conf".text = ''
		properties = {}
		rules = []
	'';
	environment.etc."pipewire/media-session.d/bluez-monitor.conf".text = ''
		properties = {
			bluez5.msbc-support = true
			bluez5.sbc-xq-support = true
		}
		rules = []
	'';
	environment.etc."pipewire/media-session.d/media-session.conf".text = ''
		properties = {}
		spa-libs = {
			api.bluez5.* = bluez5/libspa-bluez5
			api.alsa.* = alsa/libspa-alsa
			api.v4l2.* = v4l2/libspa-v4l2
			api.libcamera.* = libcamera/libspa-libcamera
		}
		modules = {
			default = [
				alsa-monitor
				alsa-seq
				bluez5
				default-nodes
				default-profile
				default-routes
				flatpak
				libcamera
				metadata
				policy-node
				portal
				restore-stream
				streams-follow-default
				suspend-node
				v4l2
			]
		}
	'';
	environment.etc."pipewire/media-session.d/v4l2-monitor.conf".text = ''
		properties = {}
		rules = []
	'';
	environment.etc."pipewire/media-session.d/with-alsa".text = "";
	environment.etc."pipewire/media-session.d/with-pulseaudio".text = "";
	environment.etc."pipewire/media-session.d/with-jack".text = "";
}
