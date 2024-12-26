{ stdenv, nodejs, runCommand, makeWrapper }: 

runCommand "prettier" {
	src = builtins.fetchGit {
		url = "https://github.com/eslint/eslint.git";
		rev = "f150f7f8fa1c992d60fcce0ede6c0557cb1f43a5";
		# ref = "v6.5.1";
	};

	nativeBuildInputs = [ nodejs ];

	outputHashAlgo = "sha256";
	outputHashMode = "recursive";
	outputHash = pkgs.lib.fakeSha256;
} ''
	mkdir -p "$out/bin"
	HOME="$PWD"

	npm config set prefix "$PWD"
	npm -g i pkg

	$PWD/bin/pkg --output "$out/bin/prettier" "$src"
''
