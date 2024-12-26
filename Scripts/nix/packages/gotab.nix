{ pkgs, lib }:

pkgs.buildGoModule rec {
	pname = "gotab";
	version = "909ef36";

	src = pkgs.fetchFromGitHub {
		owner = "dsnet";
		repo = "gotab";
		rev = version;
		sha256 = "sha256-Prjb/P0F4wDMINSC+77rOrXFIg67kxI+pbMOtz494pk=";
	};

	patchPhase = ''
		runHook prePatch

		cat<<-EOF > go.mod
		module github.com/dsnet/gotab
		EOF

		runHook postPatch
	'';

	vendorHash = null;
}
