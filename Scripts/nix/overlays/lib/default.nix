{ pkgs, inputs, ... }:

{

  nixpkgs.overlays = [
    (import ./packages.nix {
      inherit pkgs inputs;
    })
  ];
}
