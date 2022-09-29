nur: self: super:

{
	spotify-adblock = nur.repos.instantos.spotify-adblock;
	gatttool = nur.repos.mic92.gatttool;	

	gamescope = nur.repos.dukzcry.gamescope.overrideAttrs (old: {
		version = "g7167877";
		src = super.fetchFromGitHub {
			owner = "Plagman";
			repo  = "gamescope";
			rev   = "7167877";
			hash  = "sha256:199z2cbx4xybmqw3ldw003ywplbswyzah7hlwpbs6vkyly6qflpb";
			fetchSubmodules = true;
		};
	});
}
