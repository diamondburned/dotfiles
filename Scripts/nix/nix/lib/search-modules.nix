# searchModules searches for Nix modules in a directory and collects them into a
# set appropriate for use with `nixosModules` or `homeModules`.
#
# A module is considered one if it has a file named `default.nix`.

{ nixpkgs, globset, ... }@inputs:

{
  root,
  nixFile ? "default.nix",
  extraModules ? { },
}:

with builtins;
with nixpkgs.lib;

let
  modules = nixpkgs.lib.fileset.toSource {
    inherit root;
    fileset = globset.lib.glob root "*/${nixFile}";
  };
in
(mapAttrs (name: _: import (root + "/${name}/${nixFile}")) (builtins.readDir modules))
// extraModules
