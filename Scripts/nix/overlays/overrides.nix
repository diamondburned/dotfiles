self: super:

let
  lib = super.lib;
in
{
  # I don't care!!!!!! Nixpkgs, stop doing this!!
  pkgconfig = self.pkg-config;

  autoPatchelf =
    {
      pkg,
      buildInputs ? [ ],
    }:

    super.stdenv.mkDerivation {
      name = "${pkg.name}-patched";

      phases = [
        "installPhase"
        "fixupPhase"
      ];
      buildInputs = buildInputs;
      nativeBuildInputs = with super; [ autoPatchelfHook ];

      installPhase = ''
        mkdir -p $out
        cp -ra --no-preserve=mode ${pkg}/* $out
      '';
    };

  makeFirefoxProfileDesktopFile =
    {
      profile,
      name ? "Firefox (${profile})",
      icon ? "firefox",
    }:
    super.makeDesktopItem {
      name = "firefox-${profile}.desktop";
      # bin/find-desktop Firefox
      desktopName = name;
      genericName = "Web Browser (${name})";
      exec = "firefox -p ${profile} %U";
      icon = icon;
      mimeTypes = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/vnd.mozilla.xul+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/ftp"
      ];
      categories = [
        "Network"
        "WebBrowser"
      ];
    };
}
