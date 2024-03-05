{ stdenv, lib, fetchFromGitHub, kernel, bc }:

let
	modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtl8188gu";
in

stdenv.mkDerivation rec {
	pname = "rtl8188gu";
	version = "699d0ccedf2e26c3f8fcca36cca45029585aa746";

	src = fetchFromGitHub {
		owner = "lwfinger";
		repo = "rtl8188gu";
		rev = version;
		sha256 = "sha256-bcFGhtSQMX2M9h2zLSzoRT1UXYxiSH0WGLtC/JuPKTM=";
	};

	hardeningDisable = [ "pic" ];

	nativeBuildInputs = kernel.moduleBuildDependencies ++ [ bc ];

	enableParallelBuilding = true;

	makeFlags = [
		"KVER=${kernel.modDirVersion}"
		"KSRC=${kernel.dev}"
		"MODDESTDIR=${modDestDir}"
	];

	installPhase = ''
		mkdir -p ${modDestDir}
		find . -name '*.ko' -exec cp --parents '{}' ${modDestDir} \;
		find ${modDestDir} -name '*.ko' -exec xz -f '{}' \;
	'';

	meta = with lib; {
		description = "Realtek RTL8188GU driver";
		platforms = platforms.linux;
	};
}
