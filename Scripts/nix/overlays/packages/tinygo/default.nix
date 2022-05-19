{ pkgs, lib, fetchgit, go, git, cacert, llvmPackages_10 }:

let src = fetchgit {
		url = "https://github.com/tinygo-org/tinygo.git";
		rev = "a9ba6ebad9ad85cacd9674a1af9229489a811f68";
		sha256 = "1shvqqyxhaffbwakh48ma3hwj39phw06ylqap53pwqcpv970czsm";
		fetchSubmodules = true;
	};

	deps = [ go ] ++ (with llvmPackages_10; [
		clang llvm lld libclang.out
	]);

	GOPATH = go.stdenv.mkDerivation {
		name = "tinygo-deps";

		inherit src;

		nativeBuildInputs = deps ++ [ git cacert ];

		# Not needed.
		dontBuild = true;

		installPhase = ''
			export GOCACHE=$TMPDIR/go-cache
			export GOPATH="$out/go"
			go get
			ls $out $out/go
		'';

		outputHashMode = "recursive";
		outputHashAlgo = "sha256";
		outputHash = lib.fakeSha256;

		# Doesn't work.
		dontFixup = true;
	};

in go.stdenv.mkDerivation {
	name = "tinygo";
	version = "v0.13.1";

	inherit src;

	buildInputs = deps;

	buildPhase = ''
		export GOPATH="${GOPATH}/go"
		export GOCACHE=$TMPDIR/go-cache
		go build -o tinygo
	'';

	installPhase = ''
		cp tinygo $out
	'';

	# Doesn't work.
	dontFixup = true;
}
