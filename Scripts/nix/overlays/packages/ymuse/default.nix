{ buildGoModule, lib, gnome3, go, pkg-config, git, cacert, gettext }:

let srcGenerated = go.stdenv.mkDerivation {
	name = "ymuse-src";

	src = builtins.fetchGit {
		url = "https://github.com/yktoo/ymuse.git";
		ref = "v0.15";
		rev = "f236bc20a296c9eed88847c67e02683bf259f063";
	};

	impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
		"GIT_PROXY_COMMAND" "SOCKS_SERVER"
	];

	nativeBuildInputs = [ go git cacert gettext ];

	outputHashMode = "recursive";
	outputHashAlgo = "sha256";
	outputHash = "0j60ppmg9bj9q74fj9fbpf9n181s9npk4psjh9llrscbkqak1b35";

	configurePhase = ''
		patchShebangs resources/scripts/generate-*
	'';

	buildPhase = ''
		export GOCACHE=$TMPDIR/go-cache
		export GOPATH="$TMPDIR/go"

		go generate
		go mod vendor
	'';

	installPhase = ''
		mkdir $out
		cp -rf ./* $out/
	'';

	doCheck = false;
	dontFixup = true;
	doInstallCheck = false;
};

in buildGoModule {
	name = "ymuse";
	version = "0.15";

	src = srcGenerated;

	vendorSha256 = null;

	doCheck = false;

	buildInputs = with gnome3; [ gtk glib ];
	nativeBuildInputs = [ go pkg-config ];
}
