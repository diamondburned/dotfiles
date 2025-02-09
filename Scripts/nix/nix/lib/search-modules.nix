{ nixpkgs, globset, ... }@inputs:

with builtins;
with nixpkgs.lib;
nixFile:
let
  root = ./modules;
  modules = nixpkgs.lib.fileset.toSource {
    inherit root;
    fileset = globset.lib.glob root "*/${nixFile}";
  };
in
mapAttrs (name: _: import (root + "/${name}/${nixFile}")) (builtins.readDir modules)
