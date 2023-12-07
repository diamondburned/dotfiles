{ config, lib, pkgs, ... }:

{
	imports = [
		<dotfiles/secrets>
		<dotfiles/cfg/keyd>
		<dotfiles/cfg/fonts>
		<dotfiles/cfg/gnome>
		<dotfiles/cfg/tailscale>
		<home-manager/nixos>
		<nixos-apple-silicon/apple-silicon-support>
		./base/configuration.nix
		./cfg/speakers # !!!: DANGEROUS
		./cfg/virtualization.nix
		./home.nix
	];

  hardware.asahi.addEdgeKernelConfig = lib.mkForce true;
  hardware.asahi.useExperimentalGPUDriver = lib.mkForce true;

	boot.kernelPackages =
		let
			kernelPackages = pkgs.linux-asahi.override {
				_kernelPatches = config.boot.kernelPatches;
				_4KBuild = config.hardware.asahi.use4KPages;
				withRust = config.hardware.asahi.withRust;
			};
			kernel' = kernelPackages.kernel;
			# kernel' = kernelPackages.kernel.override {
			# 	inherit (import <nixpkgs_older_rust> {})
			# 		rustc
			# 		rustPlatform
			# 		rust-bindgen;
			# };
			kernel = kernel'.overrideAttrs (old: {
				src = builtins.storePath <asahilinux>;
				version = "asahi-6-latest";
				unpackPhase = ''
					cp -r $(realpath $src)/. .
					chmod -R u+w .
				'';
			});
		in
			lib.mkForce (pkgs.linuxPackagesFor kernel);

	systemd.services.mount-asahi = {
		enable = true;
		script = ''
			/run/wrappers/bin/mount /dev/disk/by-partuuid/$(< /proc/device-tree/chosen/asahi,efi-system-partition) /boot
		'';
		wantedBy = [ "multi-user.target" ];
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
		};
	};

	nixpkgs = {
		config = {
			allowUnfree = true;
		};
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
		# Allow ports for Tailscale.
		allowedTCPPorts = [ 41641 ];
		allowedUDPPorts = [ 41641 ];
		interfaces."tailscale0" = {
			allowedTCPPortRanges = [ { from = 0; to = 65535; } ];
			allowedUDPPortRanges = [ { from = 0; to = 65535; } ];
		};
	};

	# Workaround to fix audio on boot.
	# See tpwrules/nixos-apple-silicon#54.
	systemd.services.fix-jack-dac-volume = {
		script = ''
			amixer -c 0 set 'Jack Mixer' 100%
			amixer -c 0 set 'Speaker Playback Mux' Primary
		'';
		path = with pkgs; [ alsa-utils ];
		after = [ "sound.target" ];
		requires = [ "sound.target" ];
		wantedBy = [ "multi-user.target" ];
		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
		};
	};

	services.earlyoom = {
		enable = true;
		enableNotifications = true;
		freeSwapThreshold = 15;
		freeSwapKillThreshold = 5;
	};

	nix.settings.cores = lib.mkForce 8;
	nix.settings.max-jobs = lib.mkForce 1;

	hardware.bluetooth = {
		enable = true;
		package = pkgs.bluez5-experimental;
	};

	services.xserver.videoDrivers = [ "displaylink" "modesetting" ];
}
