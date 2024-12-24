{ pkgs, config, lib, ... }:

let globalPaths = lib.makeBinPath (
		config.home-manager.users.diamond.home.packages ++
		config.environment.systemPackages
	);
		
in {
	networking.extraHosts = ''
		127.0.0.1 code.local
	'';

	services.diamondburned.xcaddy = {
		enable = true;
		config = ''
			{
				admin off
			}

			http://code.local {
				reverse_proxy * unix//tmp/code-server.sock
			}

			:8080 {
				@allowed path /Pictures/* Documents/*
				handle @allowed {
					file_server {
						browse /home/diamond/Scripts/caddy-imagebrowser/browsetmpl.html
					}
				}
			}
		'';
	};

	home-manager.users.diamond = {
		systemd.user.startServices = true;

		# systemd.user.services.code-server = {
		# 	Unit.Description = "code-server at http://code.local";
		# 	Install.WantedBy = [ "default.target" ];
		# 	Service = {
		# 		UMask = "0000"; # rwxrw-rw-
		# 		ExecStart = "${pkgs.code-server}/bin/code-server -vvv " +
		# 			"--auth none " +
		# 			"--disable-telemetry " +
		# 			"--user-data-dir %h/.config/Code/ " +
		# 			"--extensions-dir %h/.vscode/extensions/ " +
		# 			"--socket /tmp/code-server.sock";
		# 		ExecStopPost = "${pkgs.coreutils}/bin/rm /tmp/code-server.sock";
		# 		Environment = [
		# 			"PATH=${globalPaths}"
		# 		];
		# 	};
		# };
	};
}
