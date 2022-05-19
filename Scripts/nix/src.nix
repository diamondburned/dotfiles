pkgs: {
	keyd = pkgs.fetchFromGitHub {
		owner = "cidkidnix";
		repo  = "nixpkgs";
		rev   = "2df745d";
		hash  = "sha256:0sch7rypczzsgj9zgzl2h42g4y5g3h9yk9969dmpcapbk0rgkybl";
	};
	nixos-21_11 = pkgs.fetchFromGitHub {
		owner = "NixOS";
		repo  = "nixpkgs";
		rev   = "8b3398bc7587ebb79f93dfeea1b8c574d3c6dba1";
		hash  = "sha256:1yaql4cwy4vd0sfd7gmcg5wpm2sn13ggkayvfq2l4kc1i4s57xcc";
	};
}
