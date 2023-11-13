{ lib, glibc, fetchFromGitHub }:

let
	patches = with builtins; [
		(fetchurl "https://aur.archlinux.org/cgit/aur.git/plain/disable-clone3.diff?h=glibc-widevine")
		(fetchurl "https://aur.archlinux.org/cgit/aur.git/plain/0001-sys-libs-glibc-add-support-for-SHT_RELR-sections.patch?h=glibc-widevine")
		(fetchurl "https://aur.archlinux.org/cgit/aur.git/plain/0002-tls-libwidevinecdm.so-since-4.10.2252.0-has-TLS-with.patch?h=glibc-widevine")
		(fetchurl "https://aur.archlinux.org/cgit/aur.git/tree/0003-nscd-Do-not-rebuild-getaddrinfo-bug-30709.patch?h=glibc-widevine")
	];

	nixpkgs_glibc_2_35 = import (fetchFromGitHub {
		owner = "NixOS";
		repo = "nixpkgs";
		rev = "272fc53af162d1e4619d03987bc0701ec12d5df7";
		sha256 = "sha256-S8fQ9TMj/1A95Vk4V4w5E1a40E1dQ9boXJOIcj2Vv5M=";
	}) {};
in

nixpkgs_glibc_2_35.glibc.overrideAttrs (self: super: {
	name = "glibc-widevine-${super.version}";
	patches = super.patches ++ patches;
	doCheck = false;
	hardeningDisable = [ "fortify" ];
	NIX_CFLAGS_COMPILE = "-w"; # Disable warnings
})
