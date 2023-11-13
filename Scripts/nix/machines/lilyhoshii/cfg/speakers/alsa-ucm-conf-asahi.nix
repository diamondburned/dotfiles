{ lib
, fetchFromGitHub
, alsa-ucm-conf }:

(alsa-ucm-conf.overrideAttrs (oldAttrs: rec {
  src_asahi = fetchFromGitHub {
    # tracking: https://github.com/AsahiLinux/PKGBUILDs/blob/main/alsa-ucm-conf-asahi/PKGBUILD
    owner = "AsahiLinux";
    repo = "alsa-ucm-conf-asahi";
    rev = "v4";
    sha256 = "${lib.fakeSha256}";
  };

  postInstall = oldAttrs.postInstall or "" + ''
    cp -r ${src_asahi}/ucm2 $out/share/alsa
  '';
}))
