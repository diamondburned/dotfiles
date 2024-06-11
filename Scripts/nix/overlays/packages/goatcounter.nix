{ fetchFromGitHub, buildGoModule, lib, goatcounter ? null }:

if goatcounter == null then
 (buildGoModule rec {
	 pname = "goatcounter";
	 version = "v2.5.0";

	 src = fetchFromGitHub {
		 owner = "arp242";
		 repo = pname;
		 rev = version;
		 sha256 = "sha256-lwiLk/YYxX4QwSDjpU/mAikumGXYMzleRzmPjZGruZU=";
	 };

	 vendorHash = "sha256-YAb3uBWQc6hWzF1Z5cAg8RzJQSJV+6dkppfczKS832s=";

	 modRoot = ".";
	 doCheck = false;
 })
else
	goatcounter
