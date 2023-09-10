{
	lib,
	stdenv,
	fetchurl,
	gcc,
	glib,
	nspr,
	nss,
	python3,
}:

let
  mkrpath = p: "${lib.makeSearchPathOutput "lib" "lib64" p}:${lib.makeLibraryPath p}";

	debianVersion = "4.10.2252.0+3";
	widevinecdmVersion = "4.10.2257.0";
in

stdenv.mkDerivation {
  name = "chrome-widevine-cdm";

  src = fetchurl {
    url = "https://archive.raspberrypi.org/debian/pool/main/w/widevine/libwidevinecdm0_${debianVersion}_arm64.deb";
    sha256 = "1122awhw8dxckjdi3c92dfvldw94bcdz27xvqfsv8k591hhvp2y8";
  };

  unpackCmd = let
    widevineCdmPath = "./opt/WidevineCdm";
  in ''
    # Extract just WidevineCdm from upstream's .deb file
    ar p "$src" data.tar.xz | tar xJ "${widevineCdmPath}"

    # Move things around so that we don't have to reference a particular
    # chrome-* directory later.
    mv "${widevineCdmPath}" ./

    # unpackCmd wants a single output directory; let it take WidevineCdm/
    rm -rf opt
  '';

  doCheck = true;
  checkPhase = ''
    ! find -iname '*.so' -exec ldd {} + | grep 'not found'
  '';

  PATCH_RPATH = mkrpath [ gcc.cc glib nspr nss ];

  patchPhase =
    ''
      patchelf --set-rpath "$PATCH_RPATH:\$ORIGIN" _platform_specific/linux_arm64/libwidevinecdm.so
      patchelf --set-rpath "$PATCH_RPATH" _platform_specific/linux_arm64/libwidevinecdm_real.so
			${python3}/bin/python3 ${./widevinecdm-fixup.py} \
				_platform_specific/linux_arm64/libwidevinecdm_real.so \
				_platform_specific/linux_arm64/libwidevinecdm.so
			rm _platform_specific/linux_arm64/libwidevinecdm_real.so
			chmod +x _platform_specific/linux_arm64/libwidevinecdm.so
		'';

  installPhase = ''
    mkdir -p $out/WidevineCdm
    cp -a * $out/WidevineCdm/
  '';

	passthru = {
		inherit widevinecdmVersion;
	};

  meta = {
    platforms = [ "aarch64-linux" ];
    license = lib.licenses.unfree;
  };
}
