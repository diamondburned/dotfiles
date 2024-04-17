{ config, lib, pkgs, ... }:

{
	imports = [
		<dotfiles/secrets>
		<dotfiles/cfg/keyd>
		<dotfiles/cfg/fonts>
		<dotfiles/cfg/gnome>
		<dotfiles/cfg/networking>
		<home-manager/nixos>
		<nixos-apple-silicon/apple-silicon-support>
		./base/configuration.nix
		# ./cfg/speakers
		./cfg/virtualization.nix
		./cfg/displaylink.nix
		./home.nix
	];

  hardware.asahi.useExperimentalGPUDriver = lib.mkForce true;

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
		overlays = import ./overlays.nix;
	};

	programs.dconf.enable = true;
	services.dbus.packages = with pkgs; [ dconf ];

	# Make the Fn key Ctrl like on a normal keyboard.
	# The Ctrl key is swapped with the Fn key.
	boot.extraModprobeConfig = ''
		options hid-apple swap_fn_leftctrl=1
	'';

	# Silent boot.
	boot.consoleLogLevel = 0;
	boot.initrd.verbose = false;
	boot.kernelParams = [
		"quiet"
		# "plymouth.debug"
		"udev.log_level=3"
		"systemd.show_status=auto"
	];

	# Hide systemd-boot by default.
	# In case of emergency, hold down the Space key during boot.
	boot.loader.timeout = 0;

	# OEM-style splash screen.
	# TODO: this doesn't work yet.
	# boot.plymouth = {
	# 	enable = true;
	# 	extraConfig = ''
	# 		DeviceScale=2
	# 	'';
	# };

	environment.systemPackages = with pkgs; [
		nix-search
		nix-index
		tmux
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

	services.auto-cpufreq = {
		enable = true;
		settings = {
			charger = {
				# Use Asahi's own CPU governor algorithm.
				governor = "schedutil";
				turbo = "auto";
			};
			battery = {
				# Use the conservative governor to save power.
				governor = "conservative";
				# M1 is plenty fast enough without turbo.
				turbo = "never";
			};
		};
	};

	# Disable power-profiles-daemon in favor of auto-cpufreq.
	services.power-profiles-daemon.enable = false;

	# Note: the displaylink module breaks suspend.
	# We don't have it enabled right now.
	services.logind.lidSwitch = "suspend";
}
