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
	environment.etc = etcFiles; # builtins.trace (builtins.toJSON etcFiles) etcFiles;

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
