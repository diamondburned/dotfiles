{ fetchFromGitHub, buildGoModule, lib, goatcounter ? null }:

if goatcounter == null then
 (buildGoModule rec {
	 pname = "goatcounter";
	 version = "v2.5.0";

	 src = fetchFromGitHub {
		 owner = "arp242";
		 repo = pname;
		 rev = version;
		 sha256 = "sha256-LzZNDZDgMFy6CYzfc57YNPJY8O5xROZLSFm85GCZIFM";
	 };

	 vendorHash = "sha256-u+AXkAoaV3YrHyhpRjNT2CiyDO6gkM3lidgyEQNvGso=";

	 modRoot = ".";
	 doCheck = false;
 })
else
	goatcounter
