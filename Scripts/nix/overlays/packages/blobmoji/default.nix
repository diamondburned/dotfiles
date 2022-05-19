{ runCommand, pkgs, lib, fetchurl }:

let pname = "blobmoji";
	version = "v2019-06-14-Emoji-12";

in runCommand pname {
	inherit pname version;

	ttf = fetchurl {
		url = "https://github.com/C1710/blobmoji/releases/download/${version}/Blobmoji.ttf";
		sha256 = "0snvymglmvpnfgsriw2cnnqm0f4llav0jvzir6mpd17mqqhhabbh";
	};

	meta = {
		description = "Noto Emoji with extended Blob support";
		homepage = "https://github.com/C1710/blobmoji";
	};
}

''install -Dm644 "$ttf" "$out/share/fonts/truetype/$ttf"''
