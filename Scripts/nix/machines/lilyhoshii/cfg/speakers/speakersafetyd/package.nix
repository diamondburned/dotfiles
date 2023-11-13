{
	lib,
	pkg-config,
	alsa-lib,
	rustPlatform,
	fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
	pname = "speakersafetyd";
	version = "0.1.4"; # no git tags for some reason?

	src = fetchFromGitHub {
		owner = "chadmed";
		repo = "speakersafetyd";
		rev = "d1c1f0b5b903f98ad553a04e3dc33a8731a58b28";
		sha256 = "sha256-Ggs1+jDeUIY7F9FLW2krRp7Qyu04D6tuw5wrJ8jsAQA=";
	};

	cargoSha256 = "sha256-hWMQGhcIM+SES2XWKvQvPYzoM1AEe2zvN3z2GXWihNs=";

	preBuild = ''
		cargo update --offline
	'';

	installPhase = ''
		export VARDIR=$TMPDIR/var # don't care
		export BINDIR=$out/bin
		export UDEVDIR=$out/lib/udev/rules.d
		export UNITDIR=$out/share/systemd/system
		export SHAREDIR=$out/share

		make
		make install
	'';

	nativeBuildInputs = [
		pkg-config
	];

	buildInputs = [
		alsa-lib
	];
}
