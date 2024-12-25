{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (inputs) lanzaboote;
in

{
  imports = [
    lanzaboote.nixosModules.lanzaboote
  ];

  services.fwupd.enable = true;

  boot = {
    bootspec.enable = true;
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      configurationLimit = 15;

      # Fix bug with sbctl. See:
      # https://github.com/nix-community/lanzaboote/issues/413
      pkiBundle = "/var/lib/sbctl";
    };
  };

  environment.systemPackages = with pkgs; [
    sbctl
  ];
}
