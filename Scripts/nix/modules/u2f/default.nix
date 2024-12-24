{ pkgs, lib, config, ... }:

let
	yubikey-touch-detector = pkgs.callPackage ./yubikey-touch-detector.nix {
		iconColor = "#ffffff";
	};
in
{
	services.udev.packages = [ pkgs.yubikey-personalization ];
	
	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};

	security.pam = {
		u2f = {
			enable = true;
		};
		services = {
			gdm-password.u2fAuth = true;
		  # login.u2fAuth = true;
		  sudo.u2fAuth = true;
		};
		mount.enable = true;
	};

	environment.systemPackages = with pkgs; [
		yubico-pam
		yubikey-manager
		yubikey-personalization
		yubikey-touch-detector
	];

	systemd.user.services.yubikey-touch-detector = {
		enable = true;
		wantedBy = [ "default.target" ];
		description = "Detects when your YubiKey is waiting for a touch";
		serviceConfig = {
			ExecStart = "${pkgs.yubikey-touch-detector}/bin/yubikey-touch-detector --libnotify";
			# Restart the service every hour to prevent it from leaking CPU.
			Restart = "always";
			RuntimeMaxSec = "1h";
		};
	};

	# Something is leaking this service, so just restart it every hour.
	# systemd.

	# systemd.user.services.yubikey-touch-detector.enable = true;
	# home-manager.users.diamond.systemd.user.services.yubikey-touch-detector.enable = true;
}
