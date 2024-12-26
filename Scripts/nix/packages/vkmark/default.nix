{ pkgs, lib }:

pkgs.stdenv.mkDerivation {
	pname = "vkmark";
	version = "master-53abc4f";

	src = pkgs.fetchFromGitHub {
		owner = "vkmark";
		repo  = "vkmark";
		rev   = "53abc4f660191051fba91ea30de084f412e7c68e";
		hash  = "sha256:01h5qx2dvl2jy0cc3pg5613dbb9ixg9fp2c4pdbaj0car0msvkxq";
	};

	buildInputs = with pkgs; [
		glm
		assimp
		vulkan-loader
		vulkan-headers
		wayland
		wayland-protocols
		mesa
		libdrm
	];

	nativeBuildInputs = with pkgs; [
		meson
		ninja
		pkg-config
	];
}
