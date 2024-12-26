{ runCommand, lib, fetchzip }:

let pname   = "openmoji";
	version = "12.3.0";
	
in runCommand pname {
	inherit pname version;

	zip = fetchzip {
		url = "https://github.com/hfg-gmuend/openmoji/releases/download/${version}/openmoji-font.zip";
		sha256 = "0vgsj6gr8m5srfmmhdva72k0b9i7icas6jwvph2c1vkhhbzqrgmp";
		stripRoot = false;
	};

	meta = {
		description = "Open source emojis for designers, developers and everyone else!";
		homepage = "https://openmoji.org/";
	};
}

''
	cd "$zip/"
	for f in *.ttf; {
		install -Dm644 "$f" "$out/share/fonts/truetype/$f"
	}
''
