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
  isNixModule = nixFile == "default.nix";

  globToDir =
    glob:
    builtins.readDir (
      nixpkgs.lib.fileset.toSource {
        inherit root;
        fileset = globset.lib.glob root glob;
      }
    );
in
{ }

// (mapAttrs (name: _: {
  inherit name;
  value = import (root + "/${name}/${nixFile}");
}) (globToDir "*/${nixFile}"))

// (optionalAttrs isNixModule (
  mapAttrs' (name: _: {
    name = builtins.replaceStrings [ ".nix" ] [ "" ] name;
    value = import (root + "/${name}");
  }) (globToDir "*.nix")
))

// extraModules
