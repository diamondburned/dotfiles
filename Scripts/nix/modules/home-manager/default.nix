{
  config,
  lib,
  pkgs,
  self,
  inputs,
  ...
}:

let
  inherit (inputs) home-manager;
in

{
  imports = [
    home-manager.nixosModules.home-manager
  ];

  home-manager.sharedModules = [
    {
      nixpkgs = {
        overlays = [
          self.overlays.overrides
          self.overlays.packages
        ];
        config = {
          allowUnfree = true;
        };
      };
    }
  ];

  home-manager.extraSpecialArgs = {
    inherit self inputs;
  };
}
