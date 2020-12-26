{ pkgs, lib, ... }: {
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

	writeBashScript = name: text: pkgList: pkgs.writeScript name ''
#!${pkgs.bash}/bin/bash
for deriv in ${lib.concatStringsSep " " pkgList}; {
	export PATH="$deriv/bin:$PATH"
}

{
${text}
} &> /tmp/nix-${name}.out
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
			IdentityFile /home/${user}/.ssh/id_server
			IdentitiesOnly yes
			ServerAliveInterval 60
			ServerAliveCountMax 10
	'';

	formatInts =
		let formatInts' = from: to: fn: list:
			if from > to then list
			else formatInts' (from + 1) to fn (list ++ [ "${fn from}" ]);

		in from: to: fn: formatInts' from to fn [];
}
