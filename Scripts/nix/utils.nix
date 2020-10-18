{ lib, ... }: {
	mkDesktopFile = { 
	    name,
	    type ? "Application", 
	    exec,
		hide ? false,
	    icon ? "",
	    comment ? "",
	    terminal ? "false",
	    categories ? "Application;Other;",
	    startupNotify ? "false",
	    extraEntries ? "",
	}: ''
		[Desktop Entry]
		Name=${name}
		Type=${type}
		Exec=${exec}
		Terminal=${terminal}
		Categories=${categories}
		StartupNotify=${startupNotify}
		${if (icon != "") then "Icon=${icon}" else ""}
		${if (comment != "") then "Comment=${comment}" else ""}
		${if hide then "NotShowIn=desktop-name" else ""}
		${extraEntries}
	'';

	outputConfig = attrs: (
		lib.attrsets.mapAttrsToList
			(k: v: { output = k; monitorConfig = v; })
			attrs
	);
}
