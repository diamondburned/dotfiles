{ pkgs, lib, ... }: {
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

	sshFallback = { tryAddr, elseAddr, host, user, port }: ''
		Match Host ${host} exec "${pkgs.libressl.nc}/bin/nc -w 1 -z ${tryAddr} ${port}"
			HostName ${tryAddr}
		Match Host ${host}
			HostName ${elseAddr}
		Host ${host}
			Port ${port}
			User ${user}
			IdentityFile   /home/${user}/.ssh/id_rsa
			IdentitiesOnly yes
			ServerAliveInterval 60
			ServerAliveCountMax 10
	'';
}
