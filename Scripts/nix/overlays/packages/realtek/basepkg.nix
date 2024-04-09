{ name, src }:

{ stdenv, lib, fetchFromGitHub, kernel, bc }:

let
	modDestDir = "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/wireless/realtek/rtl8188gu";
in

stdenv.mkDerivation {
	inherit name src;

	hardeningDisable = [ "pic" ];

	nativeBuildInputs = kernel.moduleBuildDependencies ++ [ bc ];

	enableParallelBuilding = true;

	makeFlags = [
		"ARCH=${stdenv.hostPlatform.linuxArch}"
		"KVER=${kernel.modDirVersion}"
		"KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
		"MODDESTDIR=${modDestDir}"
	];

	installPhase = ''
		mkdir -p ${modDestDir}
		find . -name '*.ko' -exec cp --parents '{}' ${modDestDir} \;
		find ${modDestDir} -name '*.ko' -exec xz -f '{}' \;
	'';

	meta = with lib; {
		platforms = platforms.linux;
	};
}
