{ config, lib, pkgs, ... }:

{
	programs.foot = {
		enable = true;
		server.enable = true;
	};

	home.pkgs = with pkgs; [
		# https://codeberg.org/dnkl/foot/issues/1598
		(pkgs.writeShellScriptBin "foot" ''
			export XCURSOR_SIZE=16
			exec ${lib.getExe pkgs.foot} "$@"
		'')
	];

	xdg = {
		enable = true;
		configFile."foot/foot.ini".source = ./foot.ini;
	};
}
