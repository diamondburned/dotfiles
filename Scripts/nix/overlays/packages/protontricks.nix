{ stdenv, lib, buildPythonApplication, fetchFromGitHub
, vdf, wineWowPackages, winetricks, zenity
}:

buildPythonApplication rec {
  pname = "protontricks";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "Matoking";
    repo = pname;
    rev = version;
    sha256 = "1v7bgr1rkm8j99s5bv45cslw01qcx8i8zb6ysfrb53qz86zgkgsn";
  };

  propagatedBuildInputs = [ vdf ];

  # The wine install shipped with Proton must run under steam's
  # chrootenv, but winetricks and zenity break when running under
  # it. See https://github.com/NixOS/nix/issues/902.
  #
  # The current workaround is to use wine from nixpkgs
  makeWrapperArgs = [
    "--set STEAM_RUNTIME 0"
    "--set-default WINE ${wineWowPackages.minimal}/bin/wine"
    "--set-default WINESERVER ${wineWowPackages.minimal}/bin/wineserver"
    "--prefix PATH : ${lib.makeBinPath [ winetricks zenity ]}"
  ];

  meta = with pkgs.lib; {
    description = "A simple wrapper for running Winetricks commands for Proton-enabled games";
    homepage = https://github.com/Matoking/protontricks;
    license = licenses.gpl3;
    platforms = with platforms; linux;
    #maintainers = with maintainers; [ metadark ];
  };
}
