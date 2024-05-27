{ config, lib, pkgs, ... }:

with lib;
with builtins;

let
	commands = {
		diamond = [
			{
				name = "volume_up";
				icon = "volume_up";
				text = "Volume Up";
				exec = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +2%";
			}
			{
				name = "volume_down";
				icon = "volume_down";
				text = "Volume Down";
				exec = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -2%";
			}
			{
				name = "obliterate_firefox";
				icon = "delete_forever";
				text = "Obliterate Firefox";
				exec = "${pkgs.procps}/bin/pkill -INT firefox";
			}
			{
				name = "check_temperature";
				icon = "thermostat";
				text = "Check Temperature";
				exec = "${pkgs.lm_sensors}/bin/sensors";
			}
			{
				name = "view_htop";
				icon = "memory";
				text = "View htop";
				exec = pkgs.writeShellScript "view-htop" ''
					if [[ "$1" == "socat" ]]; then
						stty rows 80 cols 120
						echo q \
							| ${getExe pkgs.htop} \
							| ${getExe pkgs.aha} --black --line-fix --title "htop"
					else
						${getExe pkgs.socat} - EXEC:"$BASH_SOURCE socat",pty,setsid,ctty
					fi
				'';
			}
		];
	};

	sources = import <dotfiles/nix/sources.nix> { inherit pkgs; };
	comd = (import sources.flake-compat { src = sources.comd; }).defaultNix;

	htmlDir = pkgs.linkFarm "comd-root" (mapAttrsToList (name: path: { inherit name path; }) {
		"index.html" = pkgs.writeText "comd-root-index.html" ''
			<!DOCTYPE html>
			<meta charset="utf-8">
			<meta name="viewport" content="width=device-width, initial-scale=1">
			<meta name="color-scheme" content="light dark" />
			<meta name="darkreader-lock">
			<title>${config.networking.hostName} - comd</title>
			<link rel="icon" href="/favicon.png" />
			<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.classless.min.css" />
			<link rel="stylesheet "href="https://fonts.googleapis.com/icon?family=Material+Icons">
	
			<main>
				<header>
					<nav>
						<ul>
							<li><b>comd</b></li>
						</ul>
						<ul>
							<li><span class="hostname">${config.networking.hostName}</span></li>
						</ul>
					</nav>
				</header>
	
				<section>
					<h2>diamond</h2>
					<ul class="command-list">
					${concatStringsSep "\n" (map
						(command: ''
							<li class="command">
								<form action="/api/commands/${command.name}" method="post">
									<button type="submit">
										${optionalString (command ? "icon") ''<i class="material-icons">${command.icon}</i>''}
										${command.text}
									</button>
								</form>
							</li>
						'')
						commands.diamond
					)}
					</ul>
				</section>
			</main>

			<style>
				.logo {
					font-weight: bold;
				}

				section {
					margin: var(--pico-typography-spacing-vertical) 0;
				}

				.command-list,
				.command {
					list-style: none;
					padding-left: 0;
				}

				.command button {
					text-align: left;
				}

				.material-icons {
					vertical-align: text-bottom;
				}
			</style>
		'';
		"favicon.png" = <dotfiles/static/gears-icon.png>;
	});
in

{
	# imports = [
	# 	comd.nixosModules.default
	# ];

	home-manager.users.diamond = {
		imports = [
			comd.homeModules.default
		];

		services.comd = {
			enable = true;
			listenAddr = "127.0.0.1:28475";
			config = {
				base_path = "/api/commands";
				commands = listToAttrs (map (command: {
					name = command.name;
					value = command.exec;
				}) commands.diamond);
			};
		};
	};

	diamond.tailnet-services.comd.caddyConfig = ''
		handle /api/commands* {
			reverse_proxy * localhost:28475
		}
		handle {
			root * ${htmlDir}
			file_server
		}
	'';
}
