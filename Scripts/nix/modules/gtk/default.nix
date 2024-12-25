{
  config,
  lib,
  pkgs,
  ...
}:

{
  home-manager.sharedModules = [
    {
      imports = [ ./home.nix ];
    }
  ];

  programs.gdk-pixbuf.modulePackages = with pkgs; [
    webp-pixbuf-loader
    librsvg
  ];
}
