# Do not modify this file!	It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.	Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

let utils = import ./utils.nix { inherit lib; };

	musnix = builtins.fetchGit {
		url = "https://github.com/musnix/musnix.git";
		rev = "6c3f31772c639f50f893c25fb4ee75bb0cd92c98";
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

	# # Add the camera loopback drivers.
	# boot.extraModulePackages = with config.boot.kernelPackages; [
	# 	v4l2loopback
	# ];

	boot.extraModulePackages = with config.boot.kernelPackages; [
		rtl88x2bu
	];

	# Enable the Thunderbolt 3 daemon.
	services.hardware.bolt.enable = true;

	# Kernel tweaks and such for real-time audio.
	musnix = {
		enable = true;
		soundcardPciId = "00:1f.3";
		kernel = {
			optimize = true;
			realtime = true;
			packages = pkgs.linuxPackages_5_6_rt;
		};
		rtirq.enable = true;
		das_watchdog.enable = true;
	};

	# We don't want to sacrifice battery for the above.
	powerManagement.cpuFreqGovernor = lib.mkForce "ondemand";

	services.blueman.enable = true;
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
		options = [ "nofail" ];
	};

	# Tablet drivers.
	hardware.opentabletdriver.enable = true;

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

	security.rtkit.enable = true;
	boot.kernelParams = [ "mitigations=off" ];

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
}
