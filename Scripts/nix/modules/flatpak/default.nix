{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (inputs) nix-flatpak;
in

{
  imports = [
    nix-flatpak.nixosModules.nix-flatpak
  ];

  services.flatpak.enable = true;

  # https://nixos.wiki/wiki/Fonts#Flatpak_applications_can.27t_find_system_fonts
  fonts.fontDir.enable = true;

  home-manager.sharedModules = [
    {
      imports = [
        nix-flatpak.homeManagerModules.nix-flatpak
      ];
    }
  ];
}
