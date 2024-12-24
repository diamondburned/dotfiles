{ config, lib, pkgs, ... }:

with lib;
with builtins;

let cfg = config.services.diamondburned.nokbd;

	productIDs = forEach cfg.externalKeyboards (k: k.productID);

	udevMatches = forEach cfg.externalKeyboards (k:
		(if k.productID != null then ''ENV{PRODUCT}=="${k.productID}"'' else "") +
		(if k.udevRules != null
		 then concatStringsSep ", "
			(mapAttrsToList (name: value: "${name}==\"${value}\"") k.udevRules)
		 else "")
	);

	udevRules = concatStringsSep "\n" (forEach udevMatches (matches: ''
		ACTION=="add", ${matches}, RUN+="${pkgs.systemd}/bin/systemctl --no-block start nokbd-evgrab.service"
		ACTION=="remove", ${matches}, RUN+="${pkgs.systemd}/bin/systemctl --no-block stop nokbd-evgrab.service"
	''));

	udevRulesPkg = pkgs.runCommand "nokbd-udev" {
		src = pkgs.writeText "nokbd-udev.rules" udevRules;
	} ''
		mkdir -p $out/etc/udev/rules.d
		cp $src $out/etc/udev/rules.d/99-nokbd.rules
	'';

in {
	options.services.diamondburned.nokbd = {
		enable = mkEnableOption "enokbd";

		internalKeyboard = mkOption {
			type = types.submodule {
				options = {
					inputPath = mkOption {
						type = types.str;
						example = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
						description = "The path to /dev/input* for the internal keyboard.";
					};
				};
			};
		};

		externalKeyboards = mkOption {
			type = types.listOf (types.submodule {
				options = {
					udevRules = mkOption {
						type = types.nullOr types.attrs;
						default = null;
						description = "The udev rules to match the keyboard.";
					};
					productID = mkOption {
						type = types.nullOr types.str;
						default = null;
						example = "5/5ac/24f/6701";
						description = "The product ID of the external keyboard.";
					};
				};
			});
		};
	};

	config = mkIf cfg.enable {
		systemd.services.nokbd-evgrab = {
			description = "evtest --grab for internal keyboard (${cfg.internalKeyboard.inputPath})";
			after = [ "systemd-udev-settle.service" ];
			serviceConfig = {
				Type = "simple";
				User = "root";
				ExecStart = "${pkgs.evtest}/bin/evtest --grab ${cfg.internalKeyboard.inputPath}";
				StandardOutput = "null";
				StandardError = "null";
			};
		};

		services.udev.packages = [ udevRulesPkg ];

		powerManagement.powerUpCommands = ''
			${pkgs.systemd}/bin/systemctl --no-block stop nokbd-evgrab.service
		'';
	};
}
