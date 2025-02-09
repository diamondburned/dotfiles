# combinedInputs contains all the inputs from the flake and the niv inputs
# updated using `niv` commands.

{ self, nixpkgs, ... }@inputs:

{ pkgs }:

{
}
# Mark Niv inputs with a _type:
// (nixpkgs.lib.mapAttrs (_: src: src // { _type = "niv"; }) (
  import "${self}/nix/sources.nix" {
    inherit (pkgs) system;
  }
))
# Flake inputs are already marked with a _type:
// (inputs)
