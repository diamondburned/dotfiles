{ config, lib, pkgs, ... }:

{
	sound.enable = true;
	hardware.pulseaudio.enable = false;	

	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		jack.enable = true;
		audio.enable = true;
		pulse.enable = true;
	};

	# programs.noisetorch.enable = true;

	home-manager.sharedModules = [
		{
			services.easyeffects.enable = true;

			home.packages = with pkgs; [
				helvum
			];

			# systemd.user.services.noisetorchd = {
			# 	Unit = {
			# 		Description = "NoiseTorch user daemon service";
			# 		PartOf = [ "default.target" ];
			# 		After = [ "pipewire.target" "wireplumber.target" ];
			# 	};
			# 	Install = {
			# 		WantedBy = [ "default.target" ];
			# 	};
			# 	Service = {
			# 		ExecStart = lib.getExe (pkgs.writeShellApplication {
			# 			name = "noisetorchd";
			# 			text = builtins.readFile <dotfiles/bin/noisetorchd>;
			# 			runtimeInputs = with pkgs; [
			# 				pipewire
			# 				coreutils
			# 				noisetorch
			# 			];
			# 		});
			# 		Restart = "on-failure";
			# 		RestartSec = "5s";
			# 	};
			# };
		}
	];
}
