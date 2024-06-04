{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
	self = config.hardware.v4l2-dslr;
in

{
	options.hardware.v4l2-dslr = {
		enable = mkEnableOption "Bridge a physical DSLR camera to a V4L2 loopback device";

		udevRule = mkOption {
			type = types.str;
			example = "ATTRS{idVendor}==\"046d\", ATTRS{idProduct}==\"0825\"";
			description = "The udev rule to match the camera";
		};

		videoDevice = mkOption {
			type = types.str;
			example = "/dev/video1";
			description = "The V4L2 loopback device to use";
		};
	};

	config = lib.mkIf self.enable {
		systemd.services.v4l2-dslr = {
			description = "V4L2 loopback bridge for DSLR cameras";
			script = ''
				set -eo pipefail
				gphoto2 --stdout --capture-movie | \
				ffmpeg -i - -vcodec copy -f v4l2 /dev/video0
			'';
			path = with pkgs; [
				gphoto2
				ffmpeg
			];
			serviceConfig = {
				Type = "simple";
				ExecStart = "${pkgs.v4l2loopback}/bin/v4l2loopback -r 1 -p 1 -f 30 -d /dev/video0 -i /dev/video1";
				Restart = "always";
				RestartSec = 5;
			};
		};

		services.udev.extraRules = ''
			# ${self.usbRule}
			SUBSYSTEM=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="0825", TAG+="systemd", ENV{SYSTEMD_WANTS}+="v4l2-dslr.service"
		'';
	};
}
