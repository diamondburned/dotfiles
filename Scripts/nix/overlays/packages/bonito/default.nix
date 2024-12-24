{ inputs, buildGoModule }:

let
  src = inputs.bonito;
in

buildGoModule {
  pname = "bonito";
  version = builtins.substring 0 7 src.rev;
  inherit src;

  subPackages = [ "cmd/bonito" ];
  vendorHash = "";
}
