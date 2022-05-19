{
	lib, stdenv, pkgs,
	fetchzip, autoPatchelfHook, useBin ? true, # x86 only
	fetchFromGitHub, rustPlatform,
}:

if (useBin && stdenv.system == "x86_64-linux")
then stdenv.mkDerivation rec {
	name = "intiface-cli";
	version = "v40";

	src = fetchzip {
		url = "https://github.com/intiface/intiface-cli-rs/releases/download/${version}/intiface-cli-rs-linux-x64-Release.zip";
		sha256 = "sha256:01c9vd2qi9d57fx3py0802fyzra1rsgf3nxp9gnxflqvy3vnskkw";
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
else rustPlatform.buildRustPackage rec {
	pname = "intiface-cli";
	version = "v40";
	cargoSha256 = "sha256:1cy2n6v7vbrdgcl9pz1aym39ifrqbfi9crss1yk0m2sharw1rfc1";

	src = fetchFromGitHub {
		owner = "intiface";
		repo  = "intiface-cli-rs";
		rev   = "v40";
		sha256 = "sha256:18wx83q4pvpll2q6r3c0y3cqvrxhmz21mi1873imcvccl8n99s4h";
	};

	nativeBuildInputs = with pkgs; [
		protobuf
		pkg-config
	];

	buildInputs = with pkgs; [
		udev
		libusb1
		dbus
		openssl
	];

	meta = with lib; {
		description = "Rust Intiface CLI (based on buttplug-rs)";
		homepage = "https://github.com/intiface/intiface-cli-rs";
	};
}
