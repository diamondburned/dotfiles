{ config, lib, pkgs, ... }:

{
	programs.foot = {
		enable = true;
		server = {
			enable = true;
		};
		package = pkgs.runCommandLocal "foot" {
			nativeBuildInputs = with pkgs; [
				makeWrapper
			];
		} ''
			cp -r --no-preserve=ownership ${pkgs.foot} $out
			chmod -R u+w $out
			wrapProgram $out/bin/foot \
				--set XCURSOR_SIZE 16
		'';
	};

	xdg = {
		enable = true;
		configFile."foot/foot.ini".source = ./foot.ini;
	};
}
