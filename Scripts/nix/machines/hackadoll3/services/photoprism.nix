{ config, lib, pkgs, ... }:

let
	drivePath = "/run/media/diamond/Tertiary";
in

{
	services.photoprism = {
		enable = true;
		port = 34876;
		originalsPath = "/var/lib/private/photoprism/originals";
		importPath = "/var/lib/private/photoprism/import";
		settings = {
			PHOTOPRISM_AUTH_MODE = "public";
			PHOTOPRISM_ADMIN_USER = "diamond";
			PHOTOPRISM_USERS_PATH = "Photoprism";
			PHOTOPRISM_PASSWORD_LENGTH = "0";
			PHOTOPRISM_READONLY = "true";
			PHOTOPRISM_DETECT_NSFW = "true";
			PHOTOPRISM_UPLOAD_NSFW = "true";
			PHOTOPRISM_APP_NAME = "Photoprism";
			PHOTOPRISM_APP_MODE = "minimal-ui";
			PHOTOPRISM_APP_COLOR = "#F5A9B8";
			PHOTOPRISM_HTTP_MODE = "release";
			PHOTOPRISM_SITE_URL = "http://photoprism/";
			PHOTOPRISM_SITE_TITLE = "Photoprism";
			PHOTOPRISM_SITE_DESCRIPTION = "Hosted on ${config.networking.hostName}.";
			PHOTOPRISM_JPEG_QUALITY = "91";
			PHOTOPRISM_JPEG_SIZE = "1920";
			PHOTOPRISM_PNG_SIZE = "1920";
			PHOTOPRISM_DEBUG = "true";
			PHOTOPRISM_LOG_LEVEL = "debug";
		};
	};

	fileSystems = {
		"/var/lib/private/photoprism" = {
			device = "/run/media/diamond/Tertiary/.photoprism";
  	  options = [ "bind" ];
  	};
		"/var/lib/private/photoprism/originals" = {
			device = "/run/media/diamond/Tertiary/Pictures";
  	  options = [ "bind" ];
  	};
	};

	users.users.diamond.extraGroups = [ "photoprism" ];

	# Enable http://photoprism via Tailscale.
	diamond.tailnetServices.photoprism.localPort = config.services.photoprism.port;
}
