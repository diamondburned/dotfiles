{ config, lib, pkgs, ... }:

with lib;

let prog = config.programs.rhythmbox;
	pluginOutputs = concatMapStrings (pkg: "${pkg} ") prog.plugins;

in {
	options.programs.rhythmbox = {
		enable = mkEnableOption "Rhythmbox music player";

		plugins = mkOption {
			type = types.listOf types.package;
			default = [];
			description = ''
				A list of Rhythmbox plugins.
			'';
		};

		package = mkOption {
			type = types.package;
			default = pkgs.rhythmbox;
		};
	};

	config = mkIf prog.enable {
		home.packages = [(
			(prog.package.override (old: {
				gst_plugins = with pkgs.gst_all_1; [
					gst-plugins-base
					gst-plugins-good
					gst-plugins-ugly
					gst-plugins-bad
				];
				libpeas = pkgs.libpeas.overrideAttrs(old: {
					buildInputs = old.buildInputs ++ (with pkgs; [
						rhythmbox
					]);
				});
			})).overrideAttrs (old: {
				postInstall = ''
					${old.postInstall or ""}

					for plugin in ${pluginOutputs}; {
						cp -rf $plugin/* $out/
					}
				'';
			})
		)];
	};
}
