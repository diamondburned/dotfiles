{
  pkgs,
}:

let
  inherit (pkgs) lib;

  writeBashScript' =
    pkg: name: text: pkgList:
    pkg name ''
      #!${pkgs.bash}/bin/bash
      for deriv in ${lib.concatStringsSep " " pkgList}; {
        export PATH="$deriv/bin:$PATH"
      }

      LOG_OUTFILE=/tmp/nix-${name}.out
      echo "Running at $(date)..." >> $LOG_OUTFILE

      {
        ${text}
      } &>> $LOG_OUTFILE
    '';
in
{
  mkDesktopFile =
    {
      name,
      type ? "Application",
      exec,
      hide ? false,
      icon ? "",
      hidden ? false,
      comment ? "",
      terminal ? "false",
      categories ? "Application;Other;",
      startupNotify ? "false",
      extraEntries ? "",
    }:
    ''
      [Desktop Entry]
      Name=${name}
      Type=${type}
      Exec=${exec}
      Terminal=${terminal}
      Categories=${categories}
      StartupNotify=${startupNotify}
      ${if hidden then "Hidden=true" else ""}
      ${if (icon != "") then "Icon=${icon}" else ""}
      ${if (comment != "") then "Comment=${comment}" else ""}
      ${if hide then "NotShowIn=desktop-name" else ""}
      ${extraEntries}
    '';

  writeBashScript = writeBashScript' pkgs.writeScript;
  writeBashScriptBin = writeBashScript' pkgs.writeScriptBin;

  outputConfig =
    attrs:
    (lib.attrsets.mapAttrsToList (k: v: {
      output = k;
      monitorConfig = v;
    }) attrs);

  formatInts =
    let
      formatInts' =
        from: to: fn: list:
        if from > to then list else formatInts' (from + 1) to fn (list ++ [ "${fn from}" ]);

    in
    from: to: fn:
    formatInts' from to fn [ ];
}
