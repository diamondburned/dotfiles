{ config, lib, pkgs, ... }:

{
	programs.git = {
		enable = true;
		userName  = "diamondburned";
		userEmail = "diamond@arikawa-hi.me";
		signing = {
			key = "D78C4471CE776659";
			signByDefault = true;
		};
		lfs.enable = true;
		extraConfig = {
			http = {
				cookieFile = "/home/diamond/.gitcookies";
			};
			core = {
				excludesfile = "${pkgs.writeText "gitignore" (
					builtins.concatStringsSep "\n" [
						".envrc"
						".direnv"
					]
				)}";
			};
			url = {
				"ssh://git@github.com/" = { insteadOf = "https://github.com/"; };
				"ssh://git@gitlab.com/" = { insteadOf = "https://gitlab.com/"; };
			};
			pull.rebase = true;
			push.autoSetupRemote = true;
			diff.tool = "difftastic";
			difftool = {
				prompt = false;
				difftastic.cmd = ''${pkgs.difftastic}/bin/difft "$LOCAL" "$REMOTE"'';
			};
			pager.difftool = true;
		};
	};
}
