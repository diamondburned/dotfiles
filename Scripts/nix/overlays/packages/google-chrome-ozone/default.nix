{ runCommand, writeScript, rename, findutils, google-chrome-dev }:

let google-chrome-ozone = writeScript "google-chrome-ozone" ''
		exec ${google-chrome-dev}/bin/google-chrome-unstable \
			-enable-features=UseOzonePlatform           \
			-ozone-platform=wayland "$@"  
	'';

	iconPath = "share/icons/hicolor/256x256/apps";

in runCommand "google-chrome-ozone" {} ''
	mkdir -p $out/bin $out/share/applications $out/${iconPath}

	desktopFile=$out/share/applications/google-chrome-ozone.desktop
	cp ${./google-chrome-ozone.desktop} $desktopFile
	substituteInPlace $desktopFile \
		--replace /usr/bin/google-chrome-ozone $out/bin/google-chrome-ozone

	cp  ${google-chrome-dev}/${iconPath}/google-chrome-unstable.png \
		$out/${iconPath}/google-chrome-ozone.png

	cp ${google-chrome-ozone} $out/bin/google-chrome-ozone
''
