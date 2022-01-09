{ pkgs, lib, config, ... }:

let globalPaths = lib.makeBinPath (
		config.home-manager.users.diamond.home.packages ++
		config.environment.systemPackages
	);

	writeBashScript' = pkg: name: text: pkgList: pkg name ''
#!${pkgs.bash}/bin/bash
for deriv in ${lib.concatStringsSep " " pkgList}; {
	export PATH="$deriv/bin:$PATH"
}

{
${text}
} &> /tmp/nix-${name}.out
	'';

in {
	inherit globalPaths;

	mkDesktopFile = { 
	    name,
	    type ? "Application", 
	    exec,
		hide ? false,
	    icon ? "",
		hidden ? false,
	    comment ? "",
	    terminal ? "false",
	    categories ? "Application;Other;",
	    startupNotify ? "false",
	    extraEntries ? "",
	}: ''[Desktop Entry]
Name=${name}
Type=${type}
Exec=${exec}
Terminal=${terminal}
Categories=${categories}
StartupNotify=${startupNotify}
${if hidden then "Hidden=true" else ""}
${if (icon != "") then "Icon=${icon}" else ""}
${if (comment != "") then "Comment=${comment}" else ""}
${if hide then "NotShowIn=desktop-name" else ""}
${extraEntries}
	'';

	writeBashScript    = writeBashScript' pkgs.writeScript;
	writeBashScriptBin = writeBashScript' pkgs.writeScriptBin;

	outputConfig = attrs: (
		lib.attrsets.mapAttrsToList
			(k: v: { output = k; monitorConfig = v; })
			attrs
	);

	formatInts =
		let formatInts' = from: to: fn: list:
			if from > to then list
			else formatInts' (from + 1) to fn (list ++ [ "${fn from}" ]);

		in from: to: fn: formatInts' from to fn [];

	waylandService = exec: {
		Unit = {
			Description = exec;
			After  = [ "default.target" ];
			PartOf = [ "default.target" ];
		};
		Install = {
			WantedBy = [ "default.target" ];
		};
		Service = {
			Type = "simple";
			Restart = "on-failure";
			ExecStart = exec;
			Environment = [
				"PATH=${globalPaths}"
				"WAYLAND_DISPLAY=wayland-1"
			];
			StartLimitIntervalSec = 30;
			StartLimitBurst = 5; 
		};
	}; 
}
