{ pkgs }:

let src' = pkgs.fetchFromGitHub {
		owner = "kounoike";
		repo  = "obs-virtualbg";
		rev   = "v1.1.0";
		hash  = "sha256:13m9fmcyvd2nzmcdsda2qrmb5zfvm2c3jpz429xa6zhn3q9pgv9v";
	};

	src = pkgs.runCommandLocal "obs-virtualbg-src" {
	} ''
		cp --no-preserve=mode,ownership -rf ${src'} $out
		cp ${./CMakeLists.txt} $out/CMakeLists.txt
	'';

in pkgs.stdenv.mkDerivation {
	pname   = "obs-virtualbg";
	version = "1.1.0";

	inherit src;

	propagatedBuildInputs = with pkgs; [
		python310Packages.onnx
		obs-studio
	];

	nativeBuildInputs = with pkgs; [
		cmake
	];

	cmakeFlags = [
		"-DLIBOBS_INCLUDE_DIR=${pkgs.obs-studio}/include/obs"
		"-DLIBOBS_INCLUDE_DIR=${pkgs.obs-studio}/include/obs"
	];
}
