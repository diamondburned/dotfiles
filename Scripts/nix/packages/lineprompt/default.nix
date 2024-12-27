{ buildGoApplication }:

buildGoApplication {
  name = "lineprompt";
  src = ./.;
  modules = ./gomod2nix.toml;
  meta.mainProgram = "lineprompt";
}
