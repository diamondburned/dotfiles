{ config, lib, pkgs, ... }:

{
	imports = [
		<home-manager/nixos>
		<dotfiles/secrets>
		<dotfiles/cfg/keyd>
		<dotfiles/cfg/fonts>
		<dotfiles/cfg/gnome>
		<dotfiles/cfg/tailscale>
		# ./cfg/speakers # !!!: DANGEROUS
		./home.nix
	];

	nixpkgs = {
		config.allowUnfree = true;
		overlays = [
			(import <dotfiles/overlays/overrides.nix>)
			(import <dotfiles/overlays/overrides-all.nix>)
			(import <dotfiles/overlays/packages.nix>)
		];
	};

	programs.dconf.enable = true;
	services.dbus.packages = with pkgs; [ dconf ];

	programs.fuse.userAllowOther = true;

	boot.extraModprobeConfig = ''
		options hid-apple swap_fn_leftctrl=1
	'';

	environment.systemPackages = with pkgs; [
		nix-search
		nix-index
		tmux
	];

	services.openssh.enable = true;
	users.users.diamond.openssh.authorizedKeys.keyFiles = [
		<dotfiles/public_keys>
	];

	networking.firewall = {
		enable = true;
		allowedTCPPorts = [ ];
		allowedUDPPorts = [ ];
		# Allow ports for Tailscale.
		interfaces."tailscale0" = {
			allowedTCPPorts = [ 22 80 443 ];
			allowedUDPPorts = [ 22 80 443 ];
		};
	};

	# Workaround to fix audio on boot.
	# See tpwrules/nixos-apple-silicon#54.
	systemd.services.fix-jack-dac-volume = {
		script = ''
			${pkgs.alsa-utils}/bin/amixer -c 0 set 'Jack Mixer' 100%
		'';
		after = [ "sound.target" ];
		requires = [ "sound.target" ];
		wantedBy = [ "multi-user.target" ];
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
		};
	};
}
