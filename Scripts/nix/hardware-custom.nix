# Do not modify this file!	It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.	Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

let utils = import ./utils.nix { inherit lib; };

	unstable = import <nixos-unstable> {};

	musnix = builtins.fetchGit {
		url = "https://github.com/musnix/musnix.git";
		rev = "f5053e85b0a578a335a78fa45517a8843154f46b";
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

    # Battery saver thing
    services.tlp.enable = true;

	# Do not suspend on lid close.
	services.logind.lidSwitch = "ignore";

	hardware.cpu.intel.updateMicrocode = true;

	hardware.opengl = {
		enable = true;
		driSupport32Bit = true;
		extraPackages = with pkgs; [
			vaapiIntel
			intel-media-driver
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
	# boot.kernelPackages = pkgs.linuxPackages_5_10;

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
	powerManagement.cpuFreqGovernor = lib.mkForce "ondemand";

	# Blueman sucks; use bluetoothctl.
	# services.blueman.enable = true;

	hardware.bluetooth = {
		enable = true;
		package = pkgs.bluezFull;
		config = {
			General = {
				Enable = "Source,Sink,Media,Socket";
			};
		};
	};

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

	# Enable VSync in the driver.
	services.xserver.config = ''
		Section "Device"
			Identifier "Intel Graphics"
			Driver "intel"
			Option "TearFree"        "true"
			Option "AccelMethod"     "sna"
			Option "SwapBuffersWait" "true"
		EndSection
	'';

	# Powertop is bad because of its aggressive power saving.
	powerManagement.powertop.enable = false;

	nix.maxJobs = lib.mkForce 4;

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
