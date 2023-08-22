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
			Restart = "always";
		};
	};

	# systemd.user.services.yubikey-touch-detector.enable = true;
	# home-manager.users.diamond.systemd.user.services.yubikey-touch-detector.enable = true;
}
