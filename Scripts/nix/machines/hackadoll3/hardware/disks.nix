{ pkgs, inputs, ... }:

let
  inherit (inputs) disko;
in

{
  imports = [
    disko.nixosModules.default
    ./disko/4tb-nvme.nix
  ];

  services.fstrim.enable = true;
}
