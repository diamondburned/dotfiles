{ pkgs, config, ... }: {
	networking.extraHosts = ''
		127.0.0.1 code.local
	'';

	services.diamondburned.caddy = {
		enable = true;
		config = ''
			http://code.local {
				reverse_proxy * unix//tmp/code-server.sock
			}
		'';
	};

	home-manager.users.diamond = {
		systemd.user.services.code-server = {
			Unit.Description = "code-server at http://code.local";
			Install.WantedBy = [ "default.target" ];
			Service = {
				UMask = "0000"; # rwxrw-rw-
				ExecStart = "${pkgs.code-server}/bin/code-server -vvv " +
					"--auth none " +
					"--disable-telemetry " +
					"--user-data-dir %h/.config/Code/ " +
					"--extensions-dir %h/.vscode/extensions/ " +
					"--socket /tmp/code-server.sock";
				ExecStopPost = "${pkgs.coreutils}/bin/rm /tmp/code-server.sock";
			};
		};
	};
}
