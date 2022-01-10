{ lib, fetchurl, appimageTools }:

let
  pname = "ytmdesktop";
  version = "1.15.0";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/th-ch/youtube-music/releases/download/v${version}/YouTube-Music-${version}.AppImage";
    sha256 = "16bflas2z7v5xl42f2xrc9xywz41dnx6kdpyqacrcj4jnnn4x9p4";
  };

  appimageContents = appimageTools.extract { inherit name src; };
in appimageTools.wrapType2 rec {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/{${name},${pname}}
	# ls ${appimageContents}
    install -m 444 \
        -D ${appimageContents}/youtube-music.desktop \
        -t $out/share/applications
    substituteInPlace \
        $out/share/applications/youtube-music.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "A Desktop App for YouTube Music";
    homepage = "https://ytmdesktop.app/";
    license = licenses.cc0;
    platforms = platforms.linux;
  };
}
