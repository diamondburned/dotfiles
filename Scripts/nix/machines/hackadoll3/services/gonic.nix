{ config, lib, pkgs, ... }:

{
	services.gonic = {
		enable = true;
		settings = {
			music-path = [
				"/run/media/diamond/Tertiary/Music"
				"/run/media/diamond/Tertiary/MusicCollections"
			];
			playlists-path = [];
			podcast-path = [ "/var/gonic/podcasts" ];
			cache-path = "/var/cache/gonic";
			listen-addr = "100.116.203.28:4747";
		};
	};

	# I don't care about the podcasts directory, so just make a fake one.
	systemd.tmpfiles.rules = [
		"d /var/gonic/podcasts 0777 nobody nobody -"
	];
}
