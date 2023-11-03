{ ... }:

{
	programs.zellij = {
		enable = true;
		enableBashIntegration = true;
	};

	xdg.configFile = {
		zellij = {
			target = "zellij/config.kdl";
			text = builtins.readFile ./config.kdl;
		};
	};
}
