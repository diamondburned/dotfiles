{ go }:

go.overrideAttrs (old: {
	pname = "${old.pname}-diamondburned";
	patches = (old.patches or []) ++ [
		./go-always-init-mod-with-0-patch.patch
	];
	doCheck = false;
})
