{
	lib,
	pkgconfig,
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
		sha256 = lib.fakeSha256;
	};

	cargoSha256 = lib.fakeSha256;

	nativeBuildInputs = [
		pkgconfig
	];

	buildInputs = [
		alsa-lib
	];
}
