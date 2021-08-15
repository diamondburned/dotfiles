# Do not modify this file!	It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.	Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

let utils = import ./utils.nix { inherit lib; };

	unstable = import <nixos-unstable> {};

	musnix = builtins.fetchGit {
		url = "https://github.com/musnix/musnix.git";
		rev = "fcad5573eba0a9d1ec3ed1e8e1413f601fec35fe";
	};

	blurcam = builtins.fetchGit {
		url = "https://github.com/diamondburned/blurcam.git";
		rev = "79a35253e6d81b840c3d9db8f3b0095e8a449b81";
	};

in {
	imports = [
		"${musnix }"
		"${blurcam}"
	];

	services.blurcam = {
		input  = "";
		output = "";
	};

	services.fstrim.enable = true;

	# Disable GNOME's thing in favor of TLP.
	services.power-profiles-daemon.enable = lib.mkForce false;
	services.tlp = {
		enable = true;
		settings = {
			USB_AUTOSUSPEND = "0";
		};
	};

	# LG Gram tweaks.
	systemd.tmpfiles.rules = [
		# https://01.org/linuxgraphics/gfx-docs/drm/admin-guide/laptops/lg-laptop.html
		"w /sys/devices/platform/lg-laptop/battery_care_limit - - - - 80"
		"w /sys/devices/platform/lg-laptop/fan_mode - - - - 1"
	];

	# Do not suspend on lid close.
	services.logind.lidSwitch = "ignore";

	hardware.cpu.intel.updateMicrocode = true;

	hardware.opengl = {
		enable = true;
		driSupport      = true;
		driSupport32Bit = true;
		extraPackages = with pkgs; [
			vaapiIntel
			intel-media-driver
		];
		extraPackages32 = with pkgs.pkgsi686Linux; [
			libva
			pipewire.lib
		];
	};

	# This needs to be manually stated, for some reason.
	boot.kernelModules = [ "v4l2loopback" ];

	boot.extraModulePackages = with config.boot.kernelPackages; [
		# Add the camera loopback drivers.
		v4l2loopback

		# Driver for the TP-Link Archer T3U.
		(rtl88x2bu.overrideAttrs (old: {
			src = pkgs.fetchFromGitHub {
				owner  = "RinCat";
				repo   = "RTL88x2BU-Linux-Driver";
				rev    = "657b7cfde9958e273febdeaeac579902e407f577";
				sha256 = "15gkgwp2ghg1wdp8n04a047kd8kp73y566fdc254dgxbk3ggz4xa";
			};
			patches = [];
		}))
	];

	# Refer to unstable.nix.
	boot.kernelPackages = pkgs.linuxPackages_5_13;

	# Kernel tweaks and such for real-time audio.
	musnix = {
		enable = true;
		soundcardPciId = "00:1f.3";
		# kernel = {
		# 	optimize = true;
		# 	realtime = true;
		# 	packages = pkgs.linuxPackages_5_9_rt; # TODO: update.
		# };
		rtirq.enable = true;
		das_watchdog.enable = true;
	};

	# We don't want to sacrifice battery for the above.
	powerManagement.cpuFreqGovernor = lib.mkForce "powersave";

	# Blueman sucks; use bluetoothctl.
	# services.blueman.enable = true;

	hardware.bluetooth = {
		enable = true;
		package = pkgs.bluezFull;
		settings = {
			General = {
				Enable = "Source,Sink,Media,Socket";
			};
		};
	};

	hardware.steam-hardware.enable = true;

	# Undervolting.
	services.undervolt = {
		enable = false;
		coreOffset = -45; # mV
		gpuOffset  = -5;
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

	# Tablet drivers.
	# hardware.opentabletdriver.enable = true;

	# Mouse settings.
	services.xserver.inputClassSections = [
		''
		Identifier      "libinput pointer catchall"
		MatchIsPointer  ""
		MatchProduct    "Logitech Gaming Mouse"
		MatchDevicePath "/dev/input/event*"
		Driver "libinput"
		Option "AccelerationProfile" "-1"
		Option "AccelerationScheme" "none"
		Option "AccelSpeed" "0"
		Option "AccelProfile" "flat"
		''
	];

	boot.kernelParams = [ "mitigations=off" ];

	# Requires the real-time kernel patches in Musnix.
	# security.rtkit.enable = true;

	# # Trivial graphics options.
	# boot.extraModprobeConfig = ''
	# 	options i915 fastboot=1 enable_fbc=1 enable_psr=0
	# '';

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

	boot.initrd.luks.reusePassphrases = true;
	boot.initrd.luks.devices = {
		tertiary = {
			device = "/dev/disk/by-uuid/ecd642fd-9c6e-40b0-a43a-ff05bb2b671c";
		};
	};

	environment.etc."crypttab" = {
		enable = true;
		text = ''
			tertiary-luks UUID=ecd642fd-9c6e-40b0-a43a-ff05bb2b671c none nofail
		'';
	};

	# Powertop is bad because of its aggressive power saving.
	# powerManagement.powertop.enable = true;

	nix.maxJobs = lib.mkForce 4;

	# These patches taken from cidkid's config.
	# le9db patchset to prevent I/O thrasing on high memory loads.
	boot.kernelPatches = [ 
		{
			## Prevent OOM from crashing computer hard
			name  = "pf-le9-unevictable-file";
			patch = builtins.fetchurl {
				url    = "https://gitlab.com/post-factum/pf-kernel/-/commit/ec357403078bcf24c42c468c8d4059680f383883.diff";
				sha256 = "sha256:0s6wbjag3qc5c84b6ddpzlzr7pvpj58zzs5qxmpb8r9gd37npmdc";
			};
		}
		{
			name  = "pf-le9-unevictable-anon";
			patch = builtins.fetchurl {
				url    = "https://gitlab.com/post-factum/pf-kernel/-/commit/0af9a997d0386ded3414f73e29d7119eedfaf624.diff";
				sha256 = "sha256:1ca9z90d8hvlyv55h6qn83f6737in3mvzv4ijssg453qqvxvnbym";
			};
		}
	];

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
}
