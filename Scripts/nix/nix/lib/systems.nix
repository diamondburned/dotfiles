# systems is a collection of functions to help wrangle the system attribute
# inside Flakes.

{ flake-utils, ... }@inputs:

rec {
  inherit (flake-utils.lib) defaultSystems;

  # eachSystem calls systemFunc for each default system and returns an attrset
  # with the system as key.
  eachSystem =
    systemFunc:
    builtins.listToAttrs (
      map (system: {
        name = system;
        value = systemFunc system;
      }) flake-utils.lib.defaultSystems
    );

  # eachSystemAsDefault extends eachSystem to return an attrset with
  # ${system}.default as key.
  eachSystemAsDefault =
    systemFunc:
    eachSystem (system: {
      default = systemFunc system;
    });
}
