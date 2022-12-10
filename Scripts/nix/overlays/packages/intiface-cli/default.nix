{
	lib, stdenv, pkgs,
	fetchzip, autoPatchelfHook,
	fetchFromGitHub, rustPlatform,
}:

if (stdenv.system != "x86_64-linux")
then throw "Only x86_64-linux is supported"

else stdenv.mkDerivation rec {
	name = "intiface-cli";
	version = "v50";

	src = fetchzip {
		url = "https://github.com/intiface/intiface-cli-rs/releases/download/${version}/intiface-cli-rs-linux-x64-Release.zip";
		sha256 = "sha256:1gazypmpxgk8clmbb3cg33d4f12zdr33niz1zqdgd2rp2hpnw0q5";
		stripRoot = false;
	};

	nativeBuildInputs = [
		autoPatchelfHook
	];

	buildInputs = with pkgs; [
		udev
		libusb1
		dbus
		openssl
	];
	
	sourceRoot = ".";
	
	installPhase = ''
		install -m755 -D $src/IntifaceCLI $out/bin/intiface-cli
	'';
}
