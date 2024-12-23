{
  config,
  lib,
  pkgs,
  ...
}:

let
  sources = import <dotfiles/nix/sources.nix> { inherit pkgs; };
in

{
  imports = [
    (import sources.lanzaboote).nixosModules.lanzaboote
  ];

  services.fwupd.enable = true;

  boot = {
    bootspec.enable = true;
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
      configurationLimit = 15;
    };
  };

  environment.systemPackages = with pkgs; [
    sbctl
  ];
}
