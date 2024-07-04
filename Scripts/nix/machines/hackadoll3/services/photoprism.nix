{ config, lib, pkgs, ... }:

let
	drivePath = "/run/media/diamond/Tertiary";
	driveService = "run-media-diamond-Tertiary.mount";
in

{
	services.photoprism = {
		enable = true;
		port = 34876;
		originalsPath = "${drivePath}/Pictures";
		importPath = "${drivePath}/Pictures/Photoprism";
		storagePath = "${drivePath}/.photoprism";
		settings = {
			PHOTOPRISM_AUTH_MODE = "public";
			PHOTOPRISM_ADMIN_USER = "diamond";
			PHOTOPRISM_USERS_PATH = "Photoprism";
			PHOTOPRISM_PASSWORD_LENGTH = "0";
			PHOTOPRISM_READONLY = "1";
			PHOTOPRISM_DETECT_NSFW = "1";
			PHOTOPRISM_UPLOAD_NSFW = "1";
			PHOTOPRISM_APP_NAME = "Photoprism";
			PHOTOPRISM_APP_MODE = "minimal-ui";
			PHOTOPRISM_APP_COLOR = "#F5A9B8";
			PHOTOPRISM_SITE_URL = "http://photoprism/";
			PHOTOPRISM_SITE_TITLE = "Photoprism";
			PHOTOPRISM_SITE_DESCRIPTION = "Hosted on ${config.networking.hostName}.";
			PHOTOPRISM_DATABASE_DRIVER = "sqlite";
			PHOTOPRISM_DATABASE_DSN = "${drivePath}/.photoprism";
			PHOTOPRISM_JPEG_QUALITY = "91";
			PHOTOPRISM_JPEG_SIZE = "1920";
			PHOTOPRISM_PNG_SIZE = "1920";
		};
	};

	# systemd.services.photoprism-mount-init = {
	# 	serviceConfig = {
	# 		Type = "oneshot";
	# 		ReadWritePaths = [ drivePath ];
	# 	};
	# 	script = ''
	# 		set -ex
	# 		for d in \
	# 			${drivePath}/.photoprism \
	# 			${drivePath}/.photoprism/{storage,database}; do
	#
	# 			[[ -d "$d" ]] || mkdir "$d"
	# 		done
	# 	'';
	# 	# Ensure that the Photoprism service starts after the drive is mounted and that it does not
	# 	# start if the drive is not mounted.
	# 	requiredBy = [ "photoprism.service" ];
	# 	before = [ "photoprism.service" ];
	# 	# Require the drive to be mounted.
	# 	requires = [ driveService ];
	# 	after = [ driveService ];
	# };

	# Enable http://photoprism via Tailscale.
	diamond.tailnet-services.photoprism.localPort = config.services.photoprism.port;
}
