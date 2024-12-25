{
  config,
  lib,
  pkgs,
  ...
}:

{
  fonts.fontconfig.enable = true;
  xdg.configFile."fontconfig/fonts.conf".source = ./fontconfig.xml;

  home.packages = with pkgs; [
    gucharmap
  ];
}
