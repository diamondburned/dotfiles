{ config, lib, pkgs, ... }:

let
	# cameraDevice = {
	# 	idVendor = "04a9";
	# 	idProduct = "3270";
	# };

	dslr-webcam-start = pkgs.writeShellApplication {
		name = "dslr-webcam-start";
		text = ''
			videoDevice=''${1:-/dev/video10}
			gphoto2 --stdout --capture-movie | ffmpeg -i - -vcodec copy -f v4l2 "$videoDevice"
		'';
	};
in

{
	boot.kernelModules = [ "v4l2loopback" ];
	boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
	boot.extraModprobeConfig = ''
		options v4l2loopback ${lib.concatStringsSep " " [
			''devices=3''
			''video_nr=10,11,12''
			''exclusive_caps=1,1,1''
			''card_label="Camera Loopback 1,Camera Loopback 2,Camera Loopback 3"''
		]}
	'';

	environment.systemPackages = with pkgs; [
		config.boot.kernelPackages.v4l2loopback
		gnome.cheese
		dslr-webcam-start
	];

	# Canon DSLR configuration.
	# services.udev.extraRules = 
}
