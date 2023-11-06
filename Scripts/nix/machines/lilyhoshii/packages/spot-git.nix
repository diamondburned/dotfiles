{ lib, fetchFromGitHub }:

let
	unstable = import (fetchFromGitHub {
		owner = "NixOS";
		repo = "nixpkgs";
		rev = "ace5093e36ab1e95cb9463863491bee90d5a4183";
		sha256 = "sha256-5uH27SiVFUwsTsqC5rs3kS7pBoNhtoy9QfTP9BmknGk=";
	}) {};
in

unstable.spot.overrideAttrs (old: rec {
	version = "4acafe13";
	src = fetchFromGitHub {
		owner = "xou816";
		repo = "spot";
		rev = version;
		sha256 = "sha256-4N+896Usq5qECZfoJzyEF74Lf6QJlNpKN4RuELGxgOk=";
	};
	cargoDeps = unstable.rustPlatform.fetchCargoTarball {
		inherit src;
		name = "${old.pname}-${version}-cargo-deps";
		sha256 = "sha256-yjQO5v8RS9erpUd0ih/ri0+hcCge1UoaMHMdBYaVOBk=";
	};
	nativeBuildInputs = old.nativeBuildInputs ++ (with unstable; [
		appstream
		blueprint-compiler
		gst_all_1.gstreamer
		gst_all_1.gst-plugins-base
		gst_all_1.gst-plugins-good
		gst_all_1.gst-plugins-bad
		gst_all_1.gst-plugins-ugly
	]);
	postPatch = "";
})
