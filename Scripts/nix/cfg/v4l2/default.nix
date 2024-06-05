{ config, lib, pkgs, ... }:

let
	# cameraDevice = {
	# 	idVendor = "04a9";
	# 	idProduct = "3270";
	# };

	dslr-webcam-start = pkgs.writeShellApplication {
		name = "dslr-webcam-start";
		text = ''
			gphoto2 --stdout --capture-movie | gst-launch-1.0 \
				fdsrc ! \
				decodebin ! \
				pipewiresink stream-properties="p,node.description=DSLR,node.name=DSLR,media.role=Camera,media.class=Video/Source"
		'';
		runtimeInputs = with pkgs; [
			gst_all_1.gstreamer
			gphoto2
		];
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