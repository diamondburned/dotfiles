# Do not modify this file!	It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.	Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

let utils = import ./utils { inherit lib; };

	# blurcam = builtins.fetchGit {
	# 	url = "https://github.com/diamondburned/blurcam.git";
	# 	rev = "79a35253e6d81b840c3d9db8f3b0095e8a449b81";
	# };

	rtl8188gu = config.boot.kernelPackages.rtl88x2bu.overrideAttrs (old: {
		pname = "rtl8188gu";
		version = "bb3292d";

		src = pkgs.fetchFromGitHub {
			owner  = "McMCCRU";
			repo   = "rtl8188gu";
			rev    = "bb3292d";
			sha256 = "1d7giqxpvzks97r1hixl50mxd05sxy5fja8i6jjxlkd4g2zvq6wb";
		};
	});

	wl-grab = device: mode:
		let pkg = pkgs.writeShellApplication {
			name = "wl-grab";
			text = builtins.readFile ./bin/wl-grab;
			runtimeInputs = with pkgs; [
				coreutils
				gnused
				procps
				evtest
			];
		};
		in "${pkg}/bin/wl-grab ${device} ${mode}";

in {
	imports = [
		# "${blurcam}"
		./cfg/bluetooth-hack
		./cfg/secureboot
		./cfg/u2f
	];

	# services.blurcam = {
	# 	input  = "";
	# 	output = "";
	# };

	services.fstrim.enable = true;

	services.sysprof.enable = true;

	services.hardware.bolt.enable = true;

	# LG Gram tweaks.
	systemd.tmpfiles.rules = [
		# https://01.org/linuxgraphics/gfx-docs/drm/admin-guide/laptops/lg-laptop.html
		"w /sys/devices/platform/lg-laptop/battery_care_limit - - - - 100"
	];
	# Supposedly allow the fan to ramp up to 100%.
	# We can't change this after boot for some reason.
	boot.initrd.postMountCommands = ''
		echo 1 > /sys/devices/platform/lg-laptop/fan_mode
	'';

	# Do not suspend on lid close.
	# services.logind.lidSwitch = "ignore";

	hardware.cpu.intel.updateMicrocode = true;

	environment.systemPackages = with pkgs; [
		qmk
		qmk-udev-rules
		# vkmark
	];

	hardware.opengl = {
		enable = true;
		driSupport      = true;
		driSupport32Bit = true;
		extraPackages = with pkgs; [
			mesa
			libva
			libva-utils
			vaapiIntel
			vaapi-intel-hybrid
			intel-media-driver
			libvdpau-va-gl
		];
		extraPackages32 = with pkgs.pkgsi686Linux; [
			libva
			libva-utils
			vaapiIntel
		];
	};

	# This needs to be manually stated, for some reason.
	boot.kernelModules = [
		"v4l2loopback"
		"i2c-dev"
		# "ddcci-driver"
	];

	boot.extraModulePackages = with config.boot.kernelPackages; [
		# Add the camera loopback drivers.
		v4l2loopback
		# Add DDC/CI backlight control.
		# ddcci-driver

		# Realtek driver builds itself on latest kernel challenge impossible.
		# rtl8188gu

		# Driver for the TP-Link Archer T3U.
		# (rtl88x2bu.overrideAttrs (old: {
		# 	src = pkgs.fetchFromGitHub {
		# 		owner  = "RinCat";
		# 		repo   = "RTL88x2BU-Linux-Driver";
		# 		rev    = "657b7cfde9958e273febdeaeac579902e407f577";
		# 		sha256 = "15gkgwp2ghg1wdp8n04a047kd8kp73y566fdc254dgxbk3ggz4xa";
		# 	};
		# 	patches = [];
		# }))
	];

	# Refer to unstable.nix.
	# boot.kernelPackages = pkgs.nixpkgs_unstable.linuxKernel.packages.linux_xanmod_latest;
	boot.kernelPackages = pkgs.linuxPackages_latest;
	# boot.kernelPackages = pkgs.linuxPackages_latest;
	# boot.kernelPackages = pkgs.linuxPackages-xanmod;

	# Use the Linux xanmod kernel with x86-64-v3 and LTO because we're on a
	# fucking Alder Lake CPU.
	# boot.kernelPackages = with pkgs.nixpkgs_unstable;
	# 	linuxPackagesFor linux_xanmod_latest-lto.x86_64-v3;

	hardware.firmware = with pkgs; [
		alsa-firmware
		sof-firmware
	];

	services.earlyoom = {
		enable = true;
		enableNotifications = true;
		freeSwapThreshold = 15;
		freeSwapKillThreshold = 5;
	};

	services.irqbalance.enable = true;

	# We don't want to sacrifice battery for the above.
	powerManagement.cpuFreqGovernor = lib.mkForce "powersave";

	hardware.i2c.enable = true;

	services.ddccontrol.enable = true;
	# Allow i2c access to the DDC/CI driver.
	# services.udev.extraRules = ''
	# 	KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
	# '';

	# Blueman sucks; use bluetoothctl.
	# services.blueman.enable = true;

	hardware.bluetooth = {
		enable = true;
		settings = {
			General = {
				Enable = "Source,Sink,Media,Socket";
				FastConnectable = true;
			};
		};
	};

	services.blueman.enable = true;

	hardware.steam-hardware.enable = true;

	# Undervolting.
	# services.undervolt = {
	# 	enable   = true;
	# 	useTimer = true;

	# 	temp = 95; # Celsius
	# 	coreOffset = -10; # mV
	# };

	# powerManagement.cpufreq = {
	# 	max = 2800000; # prevent overheating
	# 	min =  400000;
	# };

	# Use auto-cpufreq instead of TLP.
	# services.auto-cpufreq.enable = true;

	# services.power-profiles-daemon.enable = true;
	services.power-profiles-daemon.enable = lib.mkForce false;
	services.tlp = {
		enable = true;
		settings = {
			USB_AUTOSUSPEND = "0";
		};
	};

	fileSystems."/run/media/diamond/Data" = {
		device  = "/dev/disk/by-uuid/1cdd8e08-846d-42b1-8fef-500cf4398c4b";
		fsType  = "auto";
		options = [ "nosuid" "nodev" "nofail" ];
	};

	fileSystems."/run/media/diamond/Secondary" = {
		device  = "/dev/disk/by-uuid/1660b20d-97e1-43ab-acf3-4723d8022dec";
		fsType  = "auto";
		options = [ "nosuid" "nodev" "nofail" "x-gvfs-show" "x-gvfs-name=Secondary" ];
	};

	fileSystems."/run/media/diamond/Encrypted" = {
		device  = "/dev/disk/by-uuid/90265a61-e52e-4c34-b5e4-addc58cfc68c";
		fsType  = "auto";
		options = [ "nosuid" "nodev" "nofail" "x-gvfs-show" "noauto" ];
	};

	# swapDevices = [ {
	# 	device = "/swapfile";
	# 	options = [ "nofail" ];
	# } ];

	# My NVMe SSD is just faster than decompressing this.
	# zramSwap = {
	# 	enable        = true;
	# 	algorithm     = "lz4";
	# 	memoryPercent = 110; # %
	# };

	boot.kernel.sysctl = {
		"vm.swappiness" = lib.mkForce 90;
	};

	# Tablet drivers.
	hardware.opentabletdriver.enable = false;

	boot.kernelParams = [ "mitigations=off" "i915.verbose_state_checks=1" ];

	# Requires the real-time kernel patches in Musnix.
	security.rtkit.enable = true;

	# # Trivial graphics options.
	# boot.extraModprobeConfig = ''
	# 	options i915 fastboot=1 enable_fbc=1 enable_psr=0
	# '';

	# Brightness stuff.
	# hardware.acpilight.enable = false;
	# services.illum.enable = true;

	# Enable the Intel driver with a fallback to the current modesetting driver.
	services.xserver.videoDrivers = [ "intel" "modesetting" ];
	boot.initrd.kernelModules = [ "i915" ];
	# Crypto modules.
	boot.initrd.availableKernelModules = [
		"aesni_intel" "cryptd"
	];

	boot.initrd.luks.cryptoModules = [
		# Added above.
		"aesni_intel" "cryptd"
		# Default ones.
		"aes" "aes_generic" "blowfish" "twofish" "serpent" "cbc" "xts" "lrw"
		"sha1" "sha256" "sha512" "af_alg" "algif_skcipher"
	];

	# boot.initrd.luks.reusePassphrases = true;
	# boot.initrd.luks.devices = {
	# 	tertiary = {
	# 		device = "/dev/disk/by-uuid/ecd642fd-9c6e-40b0-a43a-ff05bb2b671c";
	# 	};

	# Powertop is bad because of its aggressive power saving.
	powerManagement.powertop.enable = false;

	# systemd.services."unfuck-powertop" = {
	# 	description = "Script to undo Powertop disabling USB ports";
	# 	after    = [ "powertop.service" ];
	# 	wantedBy = [ "powertop.service" ];
	# 	serviceConfig = {
	# 		ExecStart = pkgs.writeShellScript "unfuck-powertop.sh" ''
	# 			${pkgs.coreutils}/bin/tee /sys/bus/usb/devices/*/power/control <<< on
	# 		'';
	# 	};
	# };

	nix.settings.max-jobs = lib.mkForce 4;
	nix.settings.cores = lib.mkForce 6;

	# These patches taken from cidkid's config.
	# le9db patchset to prevent I/O thrasing on high memory loads.
	# boot.kernelPatches = [ 
	# 	{
	# 		## Prevent OOM from crashing computer hard
	# 		name  = "pf-le9-unevictable-file";
	# 		patch = builtins.fetchurl {
	# 			url    = "https://gitlab.com/post-factum/pf-kernel/-/commit/ec357403078bcf24c42c468c8d4059680f383883.diff";
	# 			sha256 = "sha256:0s6wbjag3qc5c84b6ddpzlzr7pvpj58zzs5qxmpb8r9gd37npmdc";
	# 		};
	# 	}
	# 	{
	# 		name  = "pf-le9-unevictable-anon";
	# 		patch = builtins.fetchurl {
	# 			url    = "https://gitlab.com/post-factum/pf-kernel/-/commit/0af9a997d0386ded3414f73e29d7119eedfaf624.diff";
	# 			sha256 = "sha256:1ca9z90d8hvlyv55h6qn83f6737in3mvzv4ijssg453qqvxvnbym";
	# 		};
	# 	}
	# ];

	boot.kernel.sysctl = {
		# Anon-patch
		"vm.unevictable_anon_kbytes_low" = 65536;
		"vm.unevictable_anon_kbytes_min" = 32768;
		# Regular-patch
		"vm.unevictable_file_kbytes_low" = 262144;
		"vm.unevictable_file_kbytes_min" = 131072;
	};

	# # Tweaks to give users more control over resource priorities to allow
	# # smoother audio processing and such in lower latency.
	# security.pam.loginLimits = [
	# 	{
	# 		domain = "@users";
	# 		item = "memlock";
	# 		type = "soft";
	# 		value = "1048576";
	# 	}
	# 	{
	# 		domain = "@users";
	# 		item = "memlock";
	# 		type = "hard";
	# 		value = "unlimited";
	# 	}
	# 	{
	# 		domain = "@users";
	# 		item = "rtprio";
	# 		type = "hard";
	# 		value = "49";
	# 	}
	# 	{
	# 		domain = "@users";
	# 		item = "rtprio";
	# 		type = "soft";
	# 		value = "46";
	# 	}
	# 	{
	# 		domain = "@users";
	# 		item = "priority";
	# 		type = "hard";
	# 		value = "-2";
	# 	}
	# 	{
	# 		domain = "@users";
	# 		item = "nice";
	# 		type = "soft";
	# 		value = "-19";
	# 	}
	# 	{
	# 		domain = "@users";
	# 		item = "nice";
	# 		type = "hard";
	# 		value = "-20";
	# 	}
	# 	{
	# 		domain = "@messagebus";
	# 		item = "priority";
	# 		type = "soft";
	# 		value = "-10";
	# 	}
	# ];

	sound.enable = true;
	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		jack.enable = true;
		audio.enable = true;
		pulse.enable = true;
	};
	hardware.pulseaudio.enable = false;	
}
