{ runCommand, lib, fetchFromGitHub, bash, moreutils, coreutils }:

runCommand "tbsm-0.5" {
	src = fetchFromGitHub {
		owner  = "loh-tar";
		repo   = "tbsm";
		rev    = "v0.5";
		sha256 = "166f8awqsc27a20rvvv5vp8yhkq3s3d03msd9zkxxx091cnd4va0";
	};

	# Unsure if moreutils is needed.
	buildInputs = [ bash moreutils coreutils ];
} ''
	cd $src

	install -pDm755 -t $out/bin src/tbsm
	install -pDm644 -t $out/etc/xdg/tbsm src/tbsm.conf
	install -pDm644 -t $out/etc/xdg/tbsm/themes themes/*
	install -pDm644 -t $out/share/doc/tbsm doc/*

	ln -srf -T $out/bin/tbsm $out/share/doc/tbsm/"70_SourceCode"

	patchShebangs $out/bin
''
