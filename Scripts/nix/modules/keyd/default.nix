{ pkgs, config, lib, ... }:

let
	etcFiles =
		with builtins;
		with lib;
		listToAttrs
			(map
				(n: {
					name = "keyd/${replaceStrings [".ini"] [".conf"] n}";
					value.source = builtins.toPath (./. + "/${n}");
				})
				(filter (n: hasSuffix ".ini" n) (attrNames (readDir ./.))));
in

{
	# builtins.trace (builtins.toJSON etcFiles) etcFiles;
	environment.etc = etcFiles // {
		# Fix disable while typing when using keyd.
		# See https://github.com/rvaiya/keyd/issues/66.
		"libinput/local-overrides.quirks".text = ''
			[keyd]
			MatchUdevType=keyboard
			MatchVendor=0xFAC
			AttrKeyboardIntegration=internal
		'';
	};

	systemd.services.keyd = {
		enable = true;
		description = "key remapping daemon";
		after = [ "local-fs.target" ];
		requires = [ "local-fs.target" ];
		wantedBy = [ "sysinit.target" ];
		serviceConfig = {
			Type = "simple";
			ExecStart = "${pkgs.keyd}/bin/keyd";
		};
	};
}
