{ lib, stdenv, buildGoModule }:

let pname = "transmission-web";

in buildGoModule rec {
	name = "${pname}-${version}";
	version = "stable-0.5-1";
	goPackagePath = "gitlab.com/diamondburned/${pname}";

	src = builtins.fetchGit {
		url = "https://${goPackagePath}.git";
		rev = "906085cebb3da43d64a9e65ddaf394bfd19cbeca";
	};

	vendorHash = "017zm4pqyq2ldzqwmd7m67qlhygckjvslsi9bbh308svyb439jrv";
	subPackages = [ "." ];

	meta = {
		description = "Transmission Web frontend in Go";
		homepage = "https://${goPackagePath}";
	};
}
