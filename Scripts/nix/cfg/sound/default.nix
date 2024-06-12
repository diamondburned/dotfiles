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

	programs.noisetorch.enable = true;

	home-manager.sharedModules = [
		{
			services.easyeffects.enable = lib.mkForce false;

			home.packages = with pkgs; [
				helvum
			];

			systemd.user.services.noisetorch = {
				Unit = {
					Description = "NoiseTorch user service";
					PartOf = [ "default.target" ];
					After = [ "pipewire.target" "wireplumber.target" ];
				};
				Install = {
					WantedBy = [ "default.target" ];
				};
				Service = {
					Type = "forking";
					ExecStart = "${lib.getExe pkgs.noisetorch} -i";
					Restart = "on-failure";
					RestartSec = "5s";
				};
			};
		}
	];
}
