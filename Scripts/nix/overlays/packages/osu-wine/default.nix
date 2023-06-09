{ stdenv, lib, writers, bash, wine, wget, coreutils, gnused, osu-wineprefix }:

(writers.writeBashBin "osu" ''
  set -e

  PATH="${lib.makeSearchPath "bin" [ wine wget coreutils gnused ]}:$PATH"

  prefixsrc="${osu-wineprefix}"
  basedir="''${XDG_DATA_HOME:-$HOME/.local/share}/osu-wine"
  cfgdir="''${XDG_CONFIG_HOME:-$HOME/.config}/osu-wine"
  osudir="$basedir/osu"

  WINEARCH="win32"
  WINEPREFIX="$basedir/prefix_$WINEARCH"
  WINEDEBUG="''${WINEDEBUG:--all}"

  TEMP="X:\\temp"
  USERPROFILE="X:\\userprofile"

  export WINEARCH WINEPREFIX WINEDEBUG WINEDLLPATH WINEDLLOVERRIDES TEMP USERPROFILE

  mkdir -p "$basedir" "$osudir/"{temp,userprofile} "$WINEPREFIX"

  touch "$basedir/.prefixsrc"

  [[ ! -f $basedir/.prefixsrc || $prefixsrc != $(< "$basedir/.prefixsrc") ]] && {
      echo "Creating wineprefix..."

      rm -rf "$WINEPREFIX"
      mkdir "$WINEPREFIX"

      cp $prefixsrc/*.reg "$WINEPREFIX"
      sed -i 's/C:\\\\windows\\\\temp/X:\\\\Temp/g' "$WINEPREFIX/system.reg"

      ln -s "$prefixsrc/drive_c" "$WINEPREFIX"

      mkdir -p "$WINEPREFIX/dosdevices"
      ln -s "../drive_c" "$WINEPREFIX/dosdevices/c:"
      ln -s "../../osu" "$WINEPREFIX/dosdevices/x:"

      echo "$prefixsrc" > "$basedir/.prefixsrc"

      echo "If you see an error about how the program can't be started, hit OK or No (twice)."

      wineboot -u
  }

  [[ ! -f $osudir/osu!.exe ]] &&
      wget "https://m1.ppy.sh/r/osu!install.exe" -O "$osudir/osu!.exe"

  [[ -d $cfgdir ]] &&
      cp -fv "$cfgdir"/osu!.*.cfg "$osudir"

  [[ -d "$cfgdir/skins" ]] && {
      mkdir -p "$osudir/Skins"
      ln -sf "$cfgdir"/skins/* "$osudir/Skins"
  }

  if [[ -f $1 && $1 =~ .*\.(osz|osz2|osr|osk) ]]; then
      file="$1"; shift
      mkdir -p "$osudir/Temp"
      mv -- "$FILE" "$osudir/Temp"
      exec wine "X:\\osu!.exe" "X:\\Temp\\$(basename -- "$file")" "$@"
  else
      exec wine "X:\\osu!.exe" "$@"
  fi
'') // {
  meta = with lib; {
    description = "osu! wine installer";
    license = licenses.mit;
    maintainers = with maintainers; [ tadeokondrak ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
