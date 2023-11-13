{ callPackage, ffmpeg-headless }:

callPackage
	<nixpkgs_staging/pkgs/development/libraries/pipewire>
	{ ffmpeg = ffmpeg-headless; }
