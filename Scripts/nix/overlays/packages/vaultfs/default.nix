{ stdenv, lib, buildGoModule }:

buildGoModule rec {
	pname = "vaultfs";
	version = "1.0.0";

	src = builtins.fetchGit {
		url = "https://github.com/asteris-llc/vaultfs.git";
		rev = "0beb1e2aa631faae7a3a9936a5e10767a418db28";
	};

	meta = {
		homepage = "https://github.com/asteris-llc/vaultfs";
		description = "Vault filesystem";
	};
}
