{ buildGoModule, _inputs }:

let
  inherit (_inputs) nix-bonito;
in

buildGoModule {
  pname = "bonito";
  src = nix-bonito;
  version = builtins.substring 0 7 nix-bonito.rev;

  subPackages = [ "cmd/bonito" ];
  vendorHash = "sha256-ZFYcxa85vvI6w1NMHfgyqfKdyiBtCUYUqU9c+APCFZ8=";
}
