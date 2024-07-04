{ config, lib, pkgs, ... }:

let
	drivePath = "/run/media/diamond/Tertiary";
in

{
	services.photoprism = {
		enable = true;
		port = 34876;
		importPath = "/pictures/Photoprism";
		originalsPath = "/pictures";
		storagePath = "/photoprism";
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
			PHOTOPRISM_DATABASE_DRIVER = "sqlite";
			PHOTOPRISM_DATABASE_DSN = "/photoprism";
			PHOTOPRISM_JPEG_QUALITY = "91";
			PHOTOPRISM_JPEG_SIZE = "1920";
			PHOTOPRISM_PNG_SIZE = "1920";
			PHOTOPRISM_DEBUG = "true";
			PHOTOPRISM_LOG_LEVEL = "debug";
		};
	};

	systemd.services.photoprism = {
		serviceConfig = {
			# We already manually create the user and group.
			User = lib.mkForce "photoprism";
			Group = lib.mkForce "users";
			UMask = lib.mkForce "0006";
			DynamicUser = lib.mkForce false;
			BindPaths = [
				"${drivePath}/.photoprism:/photoprism:rbind"
				"${drivePath}/Pictures:/pictures:rbind"
			];
		};
		unitConfig = {
			RequiresMountsFor = [ drivePath ];
		};
	};

	users.users.photoprism = {
		group = "users";
		home = "${drivePath}/.photoprism";
		createHome = false;
		isNormalUser = true;
	};

	# Enable http://photoprism via Tailscale.
	diamond.tailnet-services.photoprism.localPort = config.services.photoprism.port;
}
